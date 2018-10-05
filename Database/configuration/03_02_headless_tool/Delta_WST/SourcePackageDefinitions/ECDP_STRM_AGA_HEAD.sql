CREATE OR REPLACE PACKAGE EcDp_Strm_AGA IS
/******************************************************************************
** Package        :  EcDp_Strm_AGA, header part
**
** $Revision: 1.4 $
**
** Purpose        :  This package is responsible for retrieving last available
**                   meter_run and orifice_plate given stream_id and daytime
**                   for a AGA streams
**
** Documentation  :  www.energy-components.com
**
** Created  : 03.12.2004 TAIPUTOH
**
** Modification history:
**
** Version  Date         Whom           Change description:
** -------  ------       -----          -------------------------------------------
**          28.10.2004   TAIPUTOH       First version
**          18.11.2004   ROV            Tracker #1797,
**                                      Updated body and header as they were swapped
**                                      Added missing descriptions and standard headings
********************************************************************/

 -- Public type declarations

FUNCTION getMeterRun(
         p_object_id stream.object_id%TYPE,
         p_daytime date,
         p_event_type varchar2)
RETURN VARCHAR2;


FUNCTION getOrificePlate(
         p_object_id stream.object_id%TYPE,
         p_daytime date,
         p_event_type varchar2)
RETURN VARCHAR2;

END EcDp_Strm_AGA;