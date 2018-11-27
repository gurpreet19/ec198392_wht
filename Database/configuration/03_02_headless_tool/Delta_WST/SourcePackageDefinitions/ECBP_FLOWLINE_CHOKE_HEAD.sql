CREATE OR REPLACE PACKAGE EcBp_Flowline_Choke IS

/****************************************************************
** Package        :  EcBp_Flowline_Choke, header part
**
** $Revision: 1.2 $
**
** Purpose        :  Provides choke conversion functions
**
** Documentation  :  www.energy-components.com
**
** Created  : 24.01.2000  Carl-Fredrik S�sen
**
** Modification history:
**
** Version  Date       Whom  Change description:
** -------  --------   ----- --------------------------------------
** 1.0      24.01.00   CFS   Initial version
**          10.08.04   Toha  Replaced sysnam + facility + flowline_no to flowline.object_id.
*****************************************************************/


--

FUNCTION convertToMilliMeter(
	-- p_sysnam 	    VARCHAR2,
	-- p_facility      VARCHAR2,
	-- p_flwl_no       VARCHAR2,
	p_object_id       VARCHAR2,
  p_daytime       DATE,
	p_choke_natural NUMBER)

RETURN NUMBER;

--

END EcBp_Flowline_Choke;