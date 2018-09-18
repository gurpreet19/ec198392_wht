CREATE OR REPLACE PACKAGE BODY Ue_Stream_Node_Diagram IS
/******************************************************************************
** Package        :  Ue_Stream_Node_Diagram, body part
**
** $Revision: 1.2 $
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
** 09-02-2015  hismahas  ECPD-29129-Input parameters p_snd_daytime and p_network_id are removed as they are not usable.
** 09-03-2015  xxhellab	 ECPD-29640-Make network id and daytime suable for SND label and add support for SND node tooltip.
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
FUNCTION label(p_object_id IN VARCHAR2, p_object_daytime DATE, p_class_name IN VARCHAR2, p_data_daytime IN DATE DEFAULT NULL, p_network_id IN VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2
IS
BEGIN
  RETURN NULL;
END label;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getNodeTooltip
-- Description    : Return stream node diagram tooltip for nodes.
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
FUNCTION getNodeTooltip(p_object_id IN VARCHAR2, p_object_daytime DATE, p_data_daytime DATE, p_class_name IN VARCHAR2, p_network_id IN VARCHAR2)
RETURN SND_TOOLTIP_CELLS
IS
BEGIN
  RETURN NULL;
END getNodeTooltip;

END Ue_Stream_Node_Diagram;