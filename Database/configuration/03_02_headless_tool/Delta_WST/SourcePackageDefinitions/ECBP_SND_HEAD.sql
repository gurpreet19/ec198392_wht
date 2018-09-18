CREATE OR REPLACE PACKAGE EcBp_SND IS

/****************************************************************
** Package        :  EcBp_SND, header part
** Stream Node Diagram(SND)
** Modification history:
**
**  Date        Whom      Change description:
** ----------  --------  --------------------------------------
** 30.01.2017 solibhar  ECPD-42709: New Screen to display live data in SND
**                                  Added the new function to find data class for given object id.
** 16.02.2017 solibhar  ECPD-42711: Added the new function to find Daily Data screen Url for given object id.
** 10.03.2017 solibhar  ECPD-43702: Changed getDailyScreenUrl function to getTvComponentId to return ctrl_tv_preprocedure component_id.
** 14.03.2017 solibhar  ECPD-43710: Changed configuration to condider Well.instrumentation_type type to choose correct screen url for daily well status.
** 20.03.2017 solibhar  ECPD-44453: Added new function getComponentLabel to find EC Screen Label for given component_id.
** 28.03.2017 solibhar  ECPD-43703: Added new functions addIntoCntxMenuItem and deleteFromCntxMenuItem to sync Context Menu entry with CNTX_MENU_ITEM table
									Removed getDailyScreenUrl function
*****************************************************************/


FUNCTION liveDataClass(
   p_object_id VARCHAR2,
   p_daytime DATE)
RETURN VARCHAR2;

FUNCTION getComponentLabel(
   p_component_id VARCHAR2)
RETURN VARCHAR2;

PROCEDURE addIntoCntxMenuItem(
	p_component_id IN VARCHAR2,
	p_object_type IN VARCHAR2);

PROCEDURE deleteFromCntxMenuItem(
	p_bf_component_action_no IN NUMBER);


END EcBp_SND;