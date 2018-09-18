CREATE OR REPLACE PACKAGE Ecdp_Flowline IS

/****************************************************************
** Package        :  EcDp_Flowline, header part
**
** $Revision: 1.10 $
**
** Purpose        :  Finds flowline properties.
**
** Documentation  :  www.energy-components.com
**
** Created  : 17.01.2000  Carl-Fredrik S?sen
**
** Modification history:
**
** Version  Date      Whom  Change description:
** -------  --------  ----- --------------------------------------
** 1.0      17.01.00  CFS   Initial version
** 3.0      21.07.00  TEJ   Added three functions for finding field for flowline
** 3.1	    04.08.00  MAO   Added function getFlwlEquipmentCode
** 3.2      29.08.00  DN    Added function calcFlowlineTypeFracDay
** 3.7      05.09.01  FBa   Added function getFlowlineType.
**          10.08.04  Toha  Replaced sysnam + facility + flowline_no to flowline.object_id.
**          23.08.04  Toha  Changed getFlwlEquipmentCode to getFlwlEquipmentId, changed equipment_type to class_name
**	    24.02.05 kaurrnar	Removed dead codes. Removed getAttributeText and getAttributeValue function
**	    04.03.05 kaurrnar	Removed findField function
**	    07.03.05  Toha  TI 1965: removed getFieldFromWebo, getFieldFromNode
** 	    17.08.05  Nazli TI 1402: added calcPflwUptime, calcIflwUptime
**          24.08.05  Nazli TI 1402: added getPflwOnStreamHrs and getIflwOnStreamHrs function
**          01.09.05  Toha  removed getPflwOnStreamHrs, getIflwOnStreamHrs based on TI 1402
*****************************************************************/

FUNCTION calcFlowlineTypeFracDay(
       p_object_id flowline.object_id%TYPE,
       p_daytime     DATE,
       p_flwl_type   VARCHAR2)

RETURN NUMBER;

FUNCTION getFlwlEquipmentId(
   p_object_id flowline.object_id%TYPE,
   p_daytime        DATE,
   p_class_name VARCHAR2,
   p_equipment_seq_no NUMBER)

RETURN VARCHAR2;

--

FUNCTION getFlowlineType(
   p_object_id flowline.object_id%TYPE,
   p_daytime        DATE
)
RETURN VARCHAR2;

FUNCTION calcPflwUptime(
   	p_object_id	flowline.object_id%TYPE,
	p_daytime DATE)
RETURN NUMBER;

FUNCTION calcIflwUptime(
   	p_object_id	flowline.object_id%TYPE,
	p_daytime DATE)
RETURN NUMBER;

END Ecdp_Flowline;