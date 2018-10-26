CREATE OR REPLACE PACKAGE EcDp_Perf_Interval IS
/****************************************************************
** Package      :  EcDp_Perf_Interval, header part
**
** $Revision: 1.1 $
**
** Purpose      :  This package defines well/reservoir related
**                 functionality.
**
** Documentation:  www.energy-components.com
**
** Created      : 19.03.2007  Olav Naerland
**
** Modification history:
**
** Version Date      Whom         Change description:
** ------- --------  ------------ -----------------------------------
**  1.0    19.03.07  Olav         First Version
**         20.03.18  leongwen     ECPD-53390: Beautify the PL/SQL codes with proper identation.
*****************************************************************/
FUNCTION getPerfIntervalPhaseFraction(
  p_well_id well.object_id%TYPE,
  p_perf_interval_id IN perf_interval.object_id%TYPE,
  p_daytime DATE,
  p_phase	VARCHAR2)
RETURN NUMBER;

FUNCTION getWellID(
  p_object_id IN perf_interval.object_id%TYPE)
RETURN VARCHAR2;

END;