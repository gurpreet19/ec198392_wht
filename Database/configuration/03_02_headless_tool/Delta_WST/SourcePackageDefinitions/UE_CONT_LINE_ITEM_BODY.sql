CREATE OR REPLACE PACKAGE BODY ue_cont_line_item IS
/****************************************************************
** Package        :  ue_cont_line_item, body part
**
** $Revision:
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created  : 07.02.2012 Dagfinn Rosnes
**
** Modification history:
**
** Version  Date         Whom   Change description:
** -------  ------       -----  --------------------------------------
******************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : InsPPATransIntLineItem
-- Description    : Project specific Interest Line Item handling for PPA transactions.
--                  INSTEAD OF UserExit, replacing the existing product solution.
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
---------------------------------------------------------------------------------------------------
PROCEDURE InsPPATransIntLineItem(p_transaction_key VARCHAR2,
                                 p_line_item_template_id VARCHAR2,
                                 p_user VARCHAR2)
--</EC-DOC>
IS

BEGIN
  NULL;
END InsPPATransIntLineItem;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : InsPPATransIntLineItemPre
-- Description    : Project specific Interest Line Item handling for PPA transactions.
--                  PRE UserExit, running BEFORE the existing product solution.
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
---------------------------------------------------------------------------------------------------
PROCEDURE InsPPATransIntLineItemPre(p_transaction_key VARCHAR2,
                                 p_line_item_template_id VARCHAR2,
                                 p_user VARCHAR2)
--</EC-DOC>
IS

BEGIN
  NULL;
END InsPPATransIntLineItemPre;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : InsPPATransIntLineItemPost
-- Description    : Project specific Interest Line Item handling for PPA transactions.
--                  POST UserExit, running AFTER the existing product solution.
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
---------------------------------------------------------------------------------------------------
PROCEDURE InsPPATransIntLineItemPost(p_transaction_key VARCHAR2,
                                 p_line_item_template_id VARCHAR2,
                                 p_user VARCHAR2)
--</EC-DOC>
IS

BEGIN
  NULL;
END InsPPATransIntLineItemPost;

END ue_cont_line_item;