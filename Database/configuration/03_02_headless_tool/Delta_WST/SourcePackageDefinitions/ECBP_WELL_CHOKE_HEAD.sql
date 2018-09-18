CREATE OR REPLACE PACKAGE EcBp_Well_Choke IS

/****************************************************************
** Package        :  EcBp_Well_Choke, header part
**
** $Revision: 1.2 $
**
** Purpose        :  Provides choke conversion functions
**
** Documentation  :  www.energy-components.com
**
** Created  : 24.01.2000  Carl-Fredrik S?sen
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- --------------------------------------
** 1.0   	24.01.00  CFS   Initial version
** 11.08.2004 mazrina    removed sysnam and update as necessary
*****************************************************************/


--

FUNCTION convertToMilliMeter(
	--p_sysnam 	    VARCHAR2,
	--p_facility      VARCHAR2,
	--p_well_no       VARCHAR2,
	p_object_id well.object_id%TYPE,
  p_daytime       DATE,
	p_choke_natural NUMBER)

RETURN NUMBER;



END EcBp_Well_Choke;