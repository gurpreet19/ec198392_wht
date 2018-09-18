CREATE OR REPLACE PACKAGE BODY ue_cargo_document IS
/******************************************************************************
** Package        :  ue_cargo_document, body part
**
** $Revision: 1.1.2.2 $
**
** Purpose        :  Handles functinality around cargo batches
**
** Documentation  :  www.energy-components.com
**
** Created  	  :  20.09.2012 	Chooy Siew Meng
**
** Modification history:
**
** Date        	Whom  			Change description:
** ------      	----- 			-----------------------------------------------------------------------------------------------
**05.12.2012    muhammah    ECPD-22515: Add procedures useDocTemplate and updateDocTemplate
********************************************************************************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : useTemplate
-- Description    :
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
PROCEDURE useTemplate(p_parcel_no NUMBER, p_template_code VARCHAR2)
--</EC-DOC>
IS

BEGIN
	ecdp_cargo_document.useTemplate(p_parcel_no, p_template_code);
END useTemplate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : useDocTemplate
-- Description    :
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
PROCEDURE useDocTemplate(p_parcel_no NUMBER, p_template_code VARCHAR2, p_la_cpy_id VARCHAR2)
--</EC-DOC>
IS

BEGIN

	ecdp_cargo_document.useDocTemplate(p_parcel_no, p_template_code, p_la_cpy_id);

END useDocTemplate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : updateDocTemplate
-- Description    :
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
PROCEDURE updateDocTemplate(p_parcel_no NUMBER, p_template_code VARCHAR2, p_la_cpy_id VARCHAR2)
--</EC-DOC>
IS

BEGIN

	ecdp_cargo_document.updateDocTemplate(p_parcel_no, p_template_code, p_la_cpy_id);

END updateDocTemplate;

END ue_cargo_document;