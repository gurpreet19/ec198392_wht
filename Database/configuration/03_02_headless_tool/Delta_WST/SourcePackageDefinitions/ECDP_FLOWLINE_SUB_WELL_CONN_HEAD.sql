CREATE OR REPLACE PACKAGE EcDp_Flowline_Sub_Well_Conn IS
/******************************************************************************
** Package        :  EcDp_Flowline_Sub_Well_Conn
**
** $Revision: 1.0 $
**
** Purpose        :  Display information about flowline=>well and well => Flowline
**
** Documentation  :  www.energy-components.com
**
** Created  : 23.09.2016  jainngou
**
** Modification history:
**
** Version  Date        Whom      Change description:
** -------  ----------  -----     -----------------------------------------------------------------------------------------------
** 1.0      22.09.2016  jainngou   ECPD-36906:Intial version
********************************************************************/

FUNCTION FlowlineIDForWell(
          p_well_id  FLOWLINE_SUB_WELL_CONN.WELL_ID%TYPE,
          p_daytime FLOWLINE_SUB_WELL_CONN.DAYTIME%TYPE)
RETURN VARCHAR2;

FUNCTION FlowlinesForWellProdDay(
          p_well_id  FLOWLINE_SUB_WELL_CONN.WELL_ID%TYPE,
          p_daytime FLOWLINE_SUB_WELL_CONN.DAYTIME%TYPE)
RETURN VARCHAR2;

FUNCTION FlowlinesForWell(
          p_well_id  FLOWLINE_SUB_WELL_CONN.WELL_ID%TYPE,
          p_daytime FLOWLINE_SUB_WELL_CONN.DAYTIME%TYPE)
RETURN VARCHAR2;

FUNCTION GetWellsOnFlowline(
           p_flowline_id  FLOWLINE_SUB_WELL_CONN.OBJECT_ID%TYPE,
           p_daytime FLOWLINE_SUB_WELL_CONN.DAYTIME%TYPE)
RETURN VARCHAR2;

PROCEDURE switchFlowlineForWell(
          p_well_id FLOWLINE_SUB_WELL_CONN.WELL_ID%TYPE,
          p_daytime FLOWLINE_SUB_WELL_CONN.DAYTIME%TYPE,
          p_indicator_no NUMBER,
          p_status NUMBER);

END EcDp_Flowline_Sub_Well_Conn;