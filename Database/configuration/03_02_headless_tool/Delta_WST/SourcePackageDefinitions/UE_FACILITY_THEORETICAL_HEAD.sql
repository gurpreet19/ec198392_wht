CREATE OR REPLACE PACKAGE Ue_Facility_Theoretical IS
/****************************************************************
** Package        :  Ue_Facility_Theoretical
**
** $Revision: 1.1 $
**
** Purpose        :  This package is responsible for supporting business functions
**                   related to Facility theoretical calculations.
**
** Documentation  :  www.energy-components.com
**
** Created  : 09.05.2013  Sarojini Rajaretnam
**
** Modification history:
**
** Date       Whom     Change description:
** ------     -------- --------------------------------------
** 09.05.2013 rajarsar ECPD-23618:Initial version.
*****************************************************************/

FUNCTION getFacilityPhaseFactorDay(p_object_id VARCHAR2, p_daytime DATE, p_phase VARCHAR2) RETURN NUMBER;

FUNCTION getFacilityMassFactorDay(p_object_id VARCHAR2, p_daytime DATE, p_phase VARCHAR2) RETURN NUMBER;

END Ue_Facility_Theoretical;