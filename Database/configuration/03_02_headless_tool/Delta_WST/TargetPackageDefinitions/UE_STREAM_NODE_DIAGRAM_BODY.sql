CREATE OR REPLACE PACKAGE BODY Ue_Stream_Node_Diagram IS
/******************************************************************************
** Package        :  Ue_Stream_Node_Diagram, body part
**
** $Revision: 1.1.50.2 $
**
** Purpose        :  Stream Node Diagram user exit package.
**
** Documentation  :  www.energy-components.com
**
** Created        :  10.04.2008	Hanne Austad
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- ------------------------------------------------------------------------------
**19-02-2014  dhavaalo		ECPD-26893-Request for an additional input parameter for Ue_Stream_Node_Diagram.label()
**09-02-2015  hismahas	  	ECPD-29949-Input parameters p_snd_daytime and p_network_id are removed as they are not usable.
********************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : label
-- Description    : Return stream node diagram label for the input object.
--
--                  Example:
--		        RETURN EcDp_Objects.GetObjName(p_object_id, p_daytime);
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION label(p_object_id IN VARCHAR2, p_daytime DATE, p_class_name IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
  RETURN NULL;
END label;

END Ue_Stream_Node_Diagram;