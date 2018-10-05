CREATE OR REPLACE PACKAGE EcDp_Equip_Downtime IS

/****************************************************************
** Package        :  EcDp_Equip_Downtime, header part
**
** $Revision: 1.1 $
**
** Purpose        :  This package is responsible for supporting business functions
**                   related to Equipment downtime.
** Documentation  :  www.energy-components.com
**
** Created  : 21.04.2017 Gaurav Chaudhary
**
** Modification history:
**
** Date        Whom       Change description:
** -------    ----------  -------- --------------------------------------
** 21.04.2017 chaudgau    ECPD-44611: Inital version
*****************************************************************/

PROCEDURE updateEndDateForChildEvent(p_event_no NUMBER, p_o_end_date DATE, p_user VARCHAR2, p_last_updated_date DATE);

PROCEDURE updateReasonCodeForChildEvent(p_event_no NUMBER, p_user VARCHAR2, p_last_updated_date DATE);

PROCEDURE updateStartDateForChildEvent(p_event_no NUMBER, p_o_start_date DATE, p_user VARCHAR2, p_last_updated_date DATE);

PROCEDURE verifyEquipDowntime(p_event_no NUMBER, p_user_name VARCHAR2);

PROCEDURE approveEquipDowntime(p_event_no NUMBER, p_user_name VARCHAR2);

END EcDp_Equip_Downtime;