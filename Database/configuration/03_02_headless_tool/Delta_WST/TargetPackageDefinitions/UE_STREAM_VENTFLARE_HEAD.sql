CREATE OR REPLACE PACKAGE ue_stream_ventflare IS
/****************************************************************
** Package        :  ue_stream_ventflare; head part
**
** $Revision: 1.4.12.2 $
**
** Purpose        :  Fucntion called for calcNormalRelease and calcUpsetRelease
**
** Documentation  :  www.energy-components.com
**
** Created        :  17.03.2010 Sarojini Rajaretnam
**
** Modification history:
**
** Date        Whom  	Change description:
** ----------  ----- 	-------------------------------------------
** 17.03.2010  rajarsar	ECPD-4828:Initial version
** 12.08.2010  rajarsar ECPD-15495:Added calcRoutineRunHours
** 02.02.2011  farhaann ECPD-16411:Renamed calcNetVol to calcGrsVol
** 16.01.2014  choooshu ECPD-26654:Added calcwellduration
** 09.04.2014  kumarsur ECPD-27329:calcGrsVol, rename to calcGrsVolMass.
*************************************************************************/

FUNCTION calcNormalRelease(p_object_id VARCHAR2, p_asset_id VARCHAR2, p_daytime DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcNormalRelease, WNDS, WNPS, RNPS);

FUNCTION calcPotensialRelease(p_object_id VARCHAR2, p_asset_id VARCHAR2, p_daytime DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcPotensialRelease, WNDS, WNPS, RNPS);

FUNCTION calcUpsetRelease(p_object_id VARCHAR2, p_asset_id VARCHAR2, p_daytime DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcUpsetRelease, WNDS, WNPS, RNPS);

FUNCTION calcNormalMTDAvg(p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcNormalMTDAvg, WNDS, WNPS, RNPS);

FUNCTION calcGrsVolMass(p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcGrsVolMass, WNDS, WNPS, RNPS);

FUNCTION calcNonRoutineEqpmFailure(p_object_id VARCHAR2, p_class_name VARCHAR2, p_daytime DATE, p_asset_id VARCHAR2, p_start_daytime DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcNonRoutineEqpmFailure, WNDS, WNPS, RNPS);

PROCEDURE addEqpmEvent(p_object_id VARCHAR2, p_daytime DATE, p_user VARCHAR2);

FUNCTION calcRoutineRunHours(p_process_unit_id VARCHAR2, p_asset_id VARCHAR2, p_daytime DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcRoutineRunHours, WNDS, WNPS, RNPS);

FUNCTION calcWellDuration(p_object_id VARCHAR2,p_class_name VARCHAR2,p_daytime DATE,  p_asset_id VARCHAR2,p_start_daytime DATE, p_well_id VARCHAR2) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcWellDuration, WNDS, WNPS, RNPS);

END ue_stream_ventflare;