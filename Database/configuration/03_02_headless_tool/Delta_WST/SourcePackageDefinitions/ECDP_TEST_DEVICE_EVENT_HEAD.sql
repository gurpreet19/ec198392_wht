CREATE OR REPLACE PACKAGE EcDp_Test_Device_Event IS
/**************************************************************
** Package:    EcDp_Test_Device_Event, header part
**
** $Revision: 1.2 $
**
** Filename:   EcDp_Test_Device_Event_head.sql
**
** Part of :   EC Kernel
**
** Purpose:
**
** General Logic:
**
** Document References:
**
**
** Created:   	14.07.2014  Leong Weng Onn
**
**
** Modification history:
**
**
** Date:       Whom:         Change description:
** --------    -----         --------------------------------------------
** 14.07.2014  leongwen      ECPD-28063 - Initial copy, re-use the procedures insertEventStatus, deleteEventStatus and updateEventStatus for test device object use.
**************************************************************/

PROCEDURE insertEventStatus(p_object_id test_device_event.object_id%TYPE, p_daytime DATE, p_user VARCHAR2);

PROCEDURE deleteEventStatus(p_object_id test_device_event.object_id%TYPE, p_daytime DATE);

PROCEDURE updateEventStatus(p_object_id test_device.object_id%TYPE, p_daytime DATE);

END;