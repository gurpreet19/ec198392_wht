CREATE OR REPLACE PACKAGE BODY ue_stream_truckticket IS
/******************************************************************************
** Package        :  ue_stream_truckticket, body part
**
** $Revision: 1.3 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created        :  23.07.2007
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------------------------------------------------------------------
** 23.07.2007	ismaiime  initial version (ECPD-6148)
********************************************************************/

PROCEDURE verifyTicket(
	p_event_no STRM_TRANSPORT_EVENT.EVENT_NO%TYPE,
	p_user VARCHAR2 DEFAULT USER)

--</EC-DOC>
IS

BEGIN

	NULL;

END verifyTicket;

END ue_stream_truckticket;