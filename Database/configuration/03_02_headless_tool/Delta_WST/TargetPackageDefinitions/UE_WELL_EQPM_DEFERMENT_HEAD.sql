CREATE OR REPLACE PACKAGE Ue_Well_Eqpm_Deferment IS
/****************************************************************
** Package        :  Ue_Well_Eqpm_Deferment
**
** $Revision: 1.2.2.4 $
**
** Purpose        :  This package is responsible for supporting business functions
**                   related to Well Constraints and Downtime Deferments.
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
** 11.07.2013 leongwen ECPD-24671 Added User Exit procedure sumFromWells
** 16.07.2013 wonggkai ECPD-24868:Added User Exit function getPotentialRate
** 26-07-2013 wonggkai ECPD-24868: Modified getPotentialRate, add p_potential_attribute as parameter to Ue_Well_Eqpm_Deferment.getPotentialRate()
** 17-09-2013 abdulmaw ECPD-24671: Added getEventLossRate.
*****************************************************************/

FUNCTION getActualVolumes(p_object_id VARCHAR2, p_phase VARCHAR2, p_daytime DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getActualVolumes, WNDS, WNPS, RNPS);

PROCEDURE sumFromWells(p_event_no NUMBER, p_user_name VARCHAR2);

FUNCTION getPotentialRate(p_event_no NUMBER, p_potential_attribute VARCHAR2) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getPotentialRate, WNDS, WNPS, RNPS);

FUNCTION getEventLossRate (p_event_no NUMBER, p_event_attribute VARCHAR2) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getEventLossRate, WNDS, WNPS, RNPS);

END Ue_Well_Eqpm_Deferment;