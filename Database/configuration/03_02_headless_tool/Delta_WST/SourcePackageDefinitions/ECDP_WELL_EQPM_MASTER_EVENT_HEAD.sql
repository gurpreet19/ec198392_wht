CREATE OR REPLACE PACKAGE EcDp_Well_EQPM_Master_Event IS
/**************************************************************************************************
** Package  :  EcDp_Well_EQPM_Master_Event
**
** $Revision: 1.3 $
**
** Purpose  :  This package handles the triggered inserting / updating of Master Events views
**
** Created:     02.07.2007 Leong WS
**
** Modification history:
**
** Date:        Whom:       Rev.  Change description:
** ----------   -----       ----  ------------------------------------------------------------------------
** 02.07.2007   Leong WS    0.1   First version
**************************************************************************************************/

   FUNCTION genEventID(p_event_type VARCHAR2, p_daytime DATE)
   RETURN VARCHAR2;

   PROCEDURE verifyMasterEvent(p_master_event_id NUMBER,
                               p_user_id VARCHAR2);

   PROCEDURE approveMasterEvent(p_master_event_id NUMBER,
                                p_user_id VARCHAR2);

END EcDp_Well_EQPM_Master_Event;