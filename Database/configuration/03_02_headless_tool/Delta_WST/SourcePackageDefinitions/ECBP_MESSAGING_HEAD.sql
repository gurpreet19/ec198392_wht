CREATE OR REPLACE PACKAGE EcBp_Messaging IS
/**************************************************************
** Package:    EcBp_Messaging
**
** $Revision: 1.3 $
**
** Filename:   EcBp_Messaging_head.sql
**
** Part of :   EC FRMW
**
** Purpose:
**
** General Logic:
**
** Document References:
**
**
** Created:   	07.02.06  Eirik Eikeberg
**
**
** Modification history:
**
**
** Date:     Whom:      Change description:
** --------  -----      --------------------------------------------
** 07.02.06   eikebeir   Created.

**************************************************************/


  /* Copy delivery method from message_contact to recipient */
  PROCEDURE copyDeliveryMethod(p_object_id VARCHAR2, p_message_no VARCHAR2, p_daytime DATE);

  /* Copy delivery method 2 from message_contact to recipient */
--  PROCEDURE copyDeliveryMethod_2(p_object_id VARCHAR2, p_message_no VARCHAR2);
  FUNCTION messageFormatCode( p_object_id VARCHAR2) RETURN VARCHAR2;
  FUNCTION GetParamSetName(p_message_distr_no NUMBER) RETURN VARCHAR2;
  FUNCTION GetParamSetValue(p_message_distr_no NUMBER) RETURN varchar2;
  FUNCTION GetParamSetValueName(p_message_distr_no NUMBER) RETURN varchar2;
  FUNCTION GetEdiSubAddress(p_company_contact_id VARCHAR2, p_edi_address_code VARCHAR2) RETURN VARCHAR2;
END EcBp_Messaging;