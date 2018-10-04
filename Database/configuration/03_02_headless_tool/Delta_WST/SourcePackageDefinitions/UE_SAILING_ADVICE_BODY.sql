CREATE OR REPLACE PACKAGE BODY UE_SAILING_ADVICE IS
/******************************************************************************
** Package        :  UE_SAILING_ADVICE, body part
**
** $Revision: 1.4 $
**
** Purpose        :  Includes user-exit functionality for send sailing advice screen
**
** Documentation  :  www.energy-components.com
**
** Created  : 02.08.2011 Ole H Steinmo
**
** Modification history:
**
** Version  Date       Whom     Change description:
** -------  ------     -----    -----------------------------------------------------------------------------------------------
**          03.07.2017 asareswi ECPD-45818: Replaced sysdate with Ecdp_Timestamp.getCurrentSysdate
*/


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : generate_message
-- Description    : Generate sailing advice message. User exit function
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
  PROCEDURE generate_message(p_parcel_no NUMBER)

--</EC-DOC>
IS

  CURSOR c_doc_instr(b_parcel_no NUMBER
                    ,b_doc_code  VARCHAR2)
  IS
  SELECT   i.company_contact_id
  ,        ec_lifting_doc_receiver.distribution_method(i.PARCEL_NO, i.COMPANY_CONTACT_ID) distr_method
  FROM     tv_lift_doc_instruction i
  WHERE    i.parcel_no = b_parcel_no
  AND      i.doc_code = b_doc_code
  AND      ( NVL(i.ORIGINAL,'N') = 'Y'
             OR NVL(i.COPIES,0) > 0);

  lv_sailing_doc_code tv_cargo_doc_template.code%TYPE;

BEGIN

  -- Projects to setup sailing advice document
  lv_sailing_doc_code := 'SAIL_ADVICE';
  FOR r_doc_instr IN c_doc_instr(p_parcel_no, lv_sailing_doc_code) LOOP

      INSERT INTO dv_sailing_advice_message(parcel_no, receiver_id, distribution_method, doc_code, created_by)
      VALUES (p_parcel_no, r_doc_instr.company_contact_id, r_doc_instr.distr_method, lv_sailing_doc_code, ecdp_context.getAppUser);

  END LOOP;

END generate_message;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : send_message
-- Description    : Send sailing advice message. User exit function
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE send_message(
  	p_sailing_message_no NUMBER)

--</EC-DOC>
IS


BEGIN

  -- Validate before sending
  validate_message_action('SEND', p_sailing_message_no);

  UPDATE dv_sailing_advice_message sam
  SET    sam.sent = Ecdp_Timestamp.getCurrentSysdate
  ,      last_updated_by = ecdp_context.getAppUser
  WHERE  sam.sailing_message_no = p_sailing_message_no;

END send_message;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : send_all_messages
-- Description    : Generate sailing advice message. User exit function
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE send_all_messages(
  	p_parcel_no NUMBER)

--</EC-DOC>
IS

  CURSOR c_latest_messages(b_parcel_no NUMBER)
  IS
  SELECT sailing_message_no
  FROM (SELECT    sailing_message_no
       ,          created_date
       ,          receiver_id
       ,          MAX(created_date) OVER (PARTITION BY receiver_id) AS max_created_date
       FROM       dv_sailing_advice_message sam
       WHERE      sam.parcel_no = b_parcel_no)
  WHERE created_date = max_created_date;


BEGIN

  -- Loop through receivers and update the latest generated messages
  FOR r_latest_messages IN c_latest_messages(p_parcel_no) LOOP

    -- Validate before sending
    validate_message_action('SEND', r_latest_messages.sailing_message_no);

    -- Projects to configure send messages to outbound tables for MHM here
    NULL;

    UPDATE dv_sailing_advice_message sam
    SET    sam.sent = Ecdp_Timestamp.getCurrentSysdate
    ,      sam.last_updated_by = ecdp_context.getAppUser
    WHERE  sam.sailing_message_no  = r_latest_messages.sailing_message_no;

  END LOOP;


END send_all_messages;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : validate_message_action
-- Description    : Validate sailing advice for delete and sending.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE validate_message_action(p_type               VARCHAR2
                                 ,p_sailing_message_no NUMBER)
IS

  e_delete EXCEPTION;
  e_send   EXCEPTION;

BEGIN

  -- Project to validate deleting/sending of messages
  IF p_type = 'DELETING' THEN
     -- Project to define action for delete
     -- Use predefined exception 20565 to raise error message if the message have been sent
     -- EXAMPLE: RAISE_APPLICATION_ERROR(-20565,'Can not delete messages which have been sent.');
     IF ec_sailing_advice_message.sent(p_sailing_message_no) IS NOT NULL THEN
        RAISE e_delete;
     END IF;
  ELSIF p_type = 'SEND' THEN
        IF ec_sailing_advice_message.sent(p_sailing_message_no) IS NOT NULL THEN
           -- Project to define action for sending
           -- Use predefined exception 20562 to raise error message if the message have been sent
           -- EXAMPLE: RAISE_APPLICATION_ERROR(-20562,'Message have already been sent');
           RAISE e_send;
        END IF;
  END IF;

EXCEPTION
   WHEN e_delete THEN
     RAISE_APPLICATION_ERROR(-20565,'Can not delete messages which have been sent.');
   WHEN e_send THEN
     RAISE_APPLICATION_ERROR(-20562,'Message have already been sent');

END validate_message_action;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : attr_presentation
-- Description    : Show red underline for latest message grouped by receivers
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION attr_presentation(p_sailing_message_no NUMBER)
RETURN VARCHAR2
IS

  CURSOR c_sailing_messages(b_parcel_no NUMBER)
  IS
  SELECT   MAX(created_date) max_generated_date
  ,        MAX(sam.sailing_message_no) max_sail_no
  ,        sam.receiver_id
  FROM     sailing_advice_message sam
  WHERE    sam.parcel_no = b_parcel_no
  GROUP BY sam.receiver_id;

  lv_pres_syntax class_attr_property_cnfg.property_value%TYPE;

BEGIN
  lv_pres_syntax := 'NORMAL';

  -- Projects to change or remove verificationStatus
  FOR r_sailing_messages IN c_sailing_messages(ec_sailing_advice_message.parcel_no(p_sailing_message_no)) LOOP
    IF p_sailing_message_no = r_sailing_messages.max_sail_no THEN
       lv_pres_syntax := ';verificationStatus=showstopper;verificationText=Latest Message!';
    END IF;
    NULL;
  END LOOP;

RETURN lv_pres_syntax;

END attr_presentation;



END UE_SAILING_ADVICE;