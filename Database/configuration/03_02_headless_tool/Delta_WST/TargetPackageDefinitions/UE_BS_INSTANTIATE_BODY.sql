CREATE OR REPLACE PACKAGE BODY ue_bs_instantiate IS
/******************************************************************************
** Package        :  ue_bs_instantiate, body part
**
** $Revision: 1.1 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created        :  18.07.2006
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------------------------------------------------------------------
** 18.07.2006	SSK  initial version (TI 3948)
********************************************************************/

PROCEDURE new_day_end(p_daytime    DATE,
                        p_to_daytime DATE DEFAULT NULL)
 --</EC-DOC>
IS

BEGIN

NULL;

END new_day_end;

END ue_bs_instantiate;