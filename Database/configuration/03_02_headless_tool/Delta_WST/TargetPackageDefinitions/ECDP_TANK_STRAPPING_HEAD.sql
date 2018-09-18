CREATE OR REPLACE PACKAGE EcDp_Tank_Strapping IS
/****************************************************************
** Package        :  EcDp_Tank_Strapping, header part
**
** $Revision: 1.7 $
**
** Purpose        :  Finds tank volumes
**
** Documentation  :  www.energy-components.com
**
** Created  : 12.10.2001  Harald Vetrhus
**
** Modification history:
**
** Version  Date       Whom  Change description:
** -------  ------     ----- --------------------------------------
**          18.02.2004 SHN   Added procedure CopyCurrentStrapping
**          29.04.2004 FBa   Removed functions findVolumeByStrappingTable, calcRoofDisplacement, findVolume, findWaterVolume
**                           Added functions findVolumeFromDip, findMassFromDip
**          24.05.2005  kaurrnar  Removed deadcodes
**          23.09.2008  LeongWen  Added Procedures of (SetPrevEndDate) and (setEnddate) to resolve the problem of TANK STRAPPING (ECPD-6308 and ECPD-7555). Also,
**                                modified the (CopyCurrentStrapping) procedure to adopt the use of IUD triggers that's to refer to DV_TANK_STRAPPING instead of
**                                TANK_STRAPPING for records insertion using DML statement.
*****************************************************************/

FUNCTION findVolumeFromDip (
	p_tank_object_id    TANK.OBJECT_ID%TYPE,
	p_dip_level			    NUMBER,
	p_daytime           DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(findVolumeFromDip, WNDS, WNPS, RNPS);

FUNCTION findMassFromDip (
	p_tank_object_id    TANK.OBJECT_ID%TYPE,
	p_dip_level			    NUMBER,
	p_daytime           DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(findMassFromDip, WNDS, WNPS, RNPS);

PROCEDURE CopyCurrentStrapping(p_daytime          DATE,
                               p_curr_object_id   VARCHAR2,
                               p_new_object_id    VARCHAR2 DEFAULT NULL);

PROCEDURE SetPrevEndDate( p_object_id     VARCHAR2,
                          p_newdaytime    DATE,
                          p_olddaytime    DATE,
                          p_DML_Type      VARCHAR2);

PROCEDURE setEnddate(p_object_id VARCHAR2, p_daytime DATE, p_type VARCHAR2);

END EcDp_Tank_Strapping;