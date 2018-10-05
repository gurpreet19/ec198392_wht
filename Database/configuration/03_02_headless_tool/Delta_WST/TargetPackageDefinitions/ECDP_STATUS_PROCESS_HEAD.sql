CREATE OR REPLACE PACKAGE EcDp_STATUS_PROCESS IS

/****************************************************************
** Package        :  EcDp_STATUS_PROCESS, header part
**
** $Revision      :
**
** Purpose        :  Delete child records.
**
** Documentation  :  www.energy-components.com
**
** Created  : 31.05.2011  Georg Høien
**
** Modification history:
**
** Version  Date         Whom          Change description:
** -------  ----------   -----------   --------------------------------------
** 1.0      31.05.2011   Georg Høien   Initial version
/****************************************************************/

PROCEDURE checkAndDeleteChildren(p_process_id VARCHAR2);

END EcDp_STATUS_PROCESS;