CREATE OR REPLACE PACKAGE EcBp_Tank_Usage IS

/****************************************************************
** Package        :  EcBp_Tank_Usage, header part
**
** $Revision: 1.6 $
**
** Purpose        :  Provides working capasity values for a given
**                   terminal,storage and day.
**
** Documentation  :  www.energy-components.com
**
** Created  : 20.06.2001  Snorre Gulbrandsen
**
** Modification history:
**
** Version  Date     	Whom  Change description:
** -------  ------   	----- --------------------------------------
**	    11.08.2004  Mazrina removed sysnam and update as necessary
**      15.02.2005  Narinder  added procedure validatePeriod
**      17.01.2012  kumarsur  ECPD-18561:Added validateOverlappingPeriod - checking for overlapping events
*****************************************************************/

FUNCTION calcTankUsageMax(
  -- p_sysnam        VARCHAR2,
	-- p_terminal_code VARCHAR2,
	-- p_storage_code  VARCHAR2,
	p_object_id     VARCHAR2,
  p_daytime  DATE)

RETURN NUMBER;


FUNCTION calcTankUsageMin(
  -- p_sysnam        VARCHAR2,
  -- p_terminal_code VARCHAR2,
	-- p_storage_code  VARCHAR2,
	p_object_id     VARCHAR2,
  p_daytime  DATE)

RETURN NUMBER;

PROCEDURE validatePeriod(p_object_id STORAGE.object_id%TYPE,
                         p_tank_id TANK.object_id%TYPE,
                         p_end_date DATE)
;

PROCEDURE validateOverlappingPeriod(p_object_id  VARCHAR2,
                                    p_daytime    DATE,
                                    p_end_date   DATE,
                                    p_tank_id VARCHAR2);

END EcBp_Tank_Usage;