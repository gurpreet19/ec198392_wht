CREATE OR REPLACE PACKAGE BODY ue_defer_loss_accounting IS
/****************************************************************
** Package        :  ue_defer_loss_accounting, body part
**
** $Revision: 1.3 $
**
** Purpose	  :  This package is responsible for supporting business functions
**             related to Loss Accounting screens.
**
** Documentation  :  www.energy-components.com
**
** Created        :  07-12-2011 Sarojini Rajaretnam
**
** Modification history:
**
** Date       Whom     Change description:
** ------     -------- --------------------------------------
** 12.12.2011  rajarsar	ECPD-19175:Initial version
*****************************************************************/

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getStrmBoeConstant                                                 --
-- Description    : user exit function
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :
--                                                                                                 --
-- Using functions:
--
--                                                                                                 --
-- Configuration                                                                           --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
FUNCTION getStrmBoeConstant(p_object_id VARCHAR2,
                        p_daytime DATE,
                        p_db_unit VARCHAR2)
--</EC-DOC>
RETURN NUMBER

IS

BEGIN

  RETURN NULL;

END getStrmBoeConstant;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getPlannedVol                                                 --
-- Description    : User exit function to retrieve planned volume.
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :
--                                                                                                 --
-- Using functions:
--
--                                                                                                 --
-- Configuration                                                                           --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
FUNCTION getPlannedVol(p_object_id VARCHAR2,
                        p_daytime DATE)
--</EC-DOC>
RETURN NUMBER

IS

BEGIN

  RETURN NULL;

END getPlannedVol;

END ue_defer_loss_accounting;