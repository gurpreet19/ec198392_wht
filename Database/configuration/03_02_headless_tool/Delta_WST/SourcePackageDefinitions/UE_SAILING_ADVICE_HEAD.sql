CREATE OR REPLACE PACKAGE ue_sailing_advice IS

/******************************************************************************
** Package        :  UE_SAILING_ADVICE, header part
**
** $Revision: 1.2 $
**
** Purpose        :  Includes user-exit functionality for send sailing advice screen
**
** Documentation  :  www.energy-components.com
**
** Created  : 02.08.2011 Ole H Steinmo
**
** Modification history:
**
** Date        Whom     Change description:
** -------     ------   -----------------------------------------------
*/


-- Public function and procedure declarations
PROCEDURE generate_message(p_parcel_no NUMBER);

PROCEDURE send_message(p_sailing_message_no NUMBER);

PROCEDURE send_all_messages(p_parcel_no NUMBER);

PROCEDURE validate_message_action(p_type               VARCHAR2
                                 ,p_sailing_message_no NUMBER);

FUNCTION attr_presentation(p_sailing_message_no NUMBER)
RETURN VARCHAR2;

END ue_sailing_advice;