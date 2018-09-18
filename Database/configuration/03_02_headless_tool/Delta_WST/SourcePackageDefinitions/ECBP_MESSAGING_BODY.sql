CREATE OR REPLACE PACKAGE BODY EcBp_Messaging IS
/**************************************************************
** Package:    EcBp_Messaging
**
** $Revision: 1.4 $
**
** Filename:   EcBp_Messaging.sql
**
** Part of :   Messaging
**
** Purpose: This package is used by the EC Messaging screens.
**
** General Logic:
**
** Document References:
**
**
** Created:     07.02.06  Eirik Eikeberg
**
**
** Modification history:
**
**
** Date:     Whom:  Change description:
** --------  ----- --------------------------------------------
** 07.02.06  eikebeir New File
**************************************************************/




/********************* Cursors *********************************/
-- Find delivery method for the contact on a specific

--CURSOR c_deliverym (p_object_id VARCHAR2) IS
--      SELECT dm.delivery_method
--      FROM ov_message_contact dm
--      WHERE dm.object_id = p_object_id;

-- Find delivery method2 for the contact on a specific
--CURSOR c_deliverym2 (p_object_id VARCHAR2 ) IS
--     SELECT dmm.delivery_method_2
--     FROM ov_message_contact dmm
--     WHERE dmm.object_id = p_object_id;




--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : copyDeliveryMethod
-- Description  : Copys the Delivery method from to recipient
--
--
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables: RECIPIENT, MESSAGE_CONTACT
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour:
--
--
---------------------------------------------------------------------------------------------------
PROCEDURE copyDeliveryMethod(p_object_id VARCHAR2, p_message_no VARCHAR2, p_daytime DATE)
--</EC-DOC>
IS
BEGIN

        UPDATE recipient
        SET delivery_method = ec_company_contact_version.delivery_method(p_object_id,p_daytime,'=<')
        WHERE object_id = p_object_id
        AND message_no = p_message_no
        AND delivery_method is null;

        UPDATE recipient
        SET delivery_method_2 = ec_company_contact_version.delivery_method_2(p_object_id,p_daytime,'=<')
        WHERE object_id = p_object_id
        AND message_no = p_message_no
        AND delivery_method_2 is null;

END copyDeliveryMethod;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure    : copyDeliveryMethod
-- Description  : Copys the Delivery method from to recipient
--
--
--
-- Preconditions:
-- Postcondition:
--
-- Using Tables: RECIPIENT, MESSAGE_CONTACT
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour:
--
--
---------------------------------------------------------------------------------------------------
--PROCEDURE copyDeliveryMethod_2(p_object_id VARCHAR2, p_message_no VARCHAR2)
--</EC-DOC>
--IS

--BEGIN

  -- FOR cur_rec IN c_deliverym2(p_object_id) LOOP

    --    UPDATE recipient
--        SET delivery_method = cur_rec.delivery_method
--        WHERE object_id = p_object_id  AND message_no = p_message_no;

--   END LOOP;

--END copyDeliveryMethod_2;

--<EC-DOC>

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : messageFormatCode
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : Message_Format
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : Returns the default Format code for a message_type
--
---------------------------------------------------------------------------------------------------
FUNCTION messageFormatCode( p_object_id VARCHAR2) RETURN VARCHAR2
--</EC-DOC>
IS

CURSOR c_format_codes IS
SELECT FORMAT_CODE,default_ext_format_ind
FROM message_format
WHERE OBJECT_ID=p_object_id
;

formatCode VARCHAR2(1000) := NULL;

BEGIN


   FOR cur_rec IN c_format_codes LOOP
       formatCode := cur_rec.format_code;
       IF (cur_rec.default_ext_format_ind='Y') THEN
         EXIT;  -- No need to loop further
       END IF;
   END LOOP;

   RETURN formatCode;

END messageFormatCode;

FUNCTION GetParamSetName(p_message_distr_no NUMBER) RETURN varchar2
IS

   CURSOR c_params IS
   SELECT parameter_name
   FROM message_distr_param
   WHERE message_distribution_no = p_message_distr_no
   order by parameter_name desc;
   lv2_return_val message_distr_param.parameter_name%TYPE;

begin

  FOR cur_param IN c_params LOOP

    lv2_return_val :=  lv2_return_val || cur_param.parameter_name || ',';

  END LOOP;
  lv2_return_val := trim(trailing ',' from lv2_return_val);
  RETURN lv2_return_val;

end GetParamSetName;

FUNCTION GetParamSetValue(p_message_distr_no NUMBER) RETURN varchar2
IS

   CURSOR c_params IS
   SELECT parameter_value
   FROM message_distr_param
   WHERE message_distribution_no = p_message_distr_no
   order by parameter_name desc;
   lv2_return_val message_distr_param.parameter_value%TYPE;

begin

  FOR cur_param IN c_params LOOP

    lv2_return_val :=
    lv2_return_val
    || cur_param.parameter_value
    || ',';

  END LOOP;
  lv2_return_val := trim(trailing ',' from lv2_return_val);
  RETURN lv2_return_val;

end GetParamSetValue;

FUNCTION GetParamSetValueName(p_message_distr_no NUMBER) RETURN varchar2
IS

   CURSOR c_params IS
   SELECT parameter_name, parameter_value, parameter_type, parameter_sub_type
   FROM message_distr_param
   WHERE message_distribution_no = p_message_distr_no
   order by parameter_name desc;
   lv2_return_val message_distr_param.parameter_name%TYPE;

begin

  FOR cur_param IN c_params LOOP

    lv2_return_val :=
    lv2_return_val
    || ecdp_client_Presentation.getname(cur_param.parameter_type, cur_param.parameter_sub_type, cur_param.parameter_value)
    || ',';

  END LOOP;
  lv2_return_val := trim(trailing ',' from lv2_return_val);
  RETURN lv2_return_val;

end GetParamSetValueName;

FUNCTION GetEdiSubAddress(p_company_contact_id varchar2, p_edi_address_code varchar2) return varchar2 is
   CURSOR c_edi IS
   SELECT EDI_SUB_ADDRESS
   FROM COMPANY_CONTACT_EDI
   WHERE OBJECT_ID = p_company_contact_id
   AND EDI_ADDRESS_CODE = p_edi_address_code;
   lv2_return_val COMPANY_CONTACT_EDI.EDI_SUB_ADDRESS%TYPE;
begin

  FOR cur_edi IN c_edi LOOP

    lv2_return_val := cur_edi.EDI_SUB_ADDRESS;

  END LOOP;
  RETURN lv2_return_val;
end GetEdiSubAddress;


End EcBp_Messaging;