CREATE OR REPLACE PACKAGE BODY ue_bs_instantiate IS
/******************************************************************************
** Package        :  ue_bs_instantiate, body part
**
** $Revision: 1.2 $
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
** 20.08.2013  KUMARSUR ECPD-24470: Added procedure new_month().
********************************************************************/

PROCEDURE new_day_end(p_daytime    DATE,
                        p_to_daytime DATE DEFAULT NULL)
 --</EC-DOC>
IS

BEGIN

NULL;

END new_day_end;

PROCEDURE new_month(p_daytime DATE, p_local_lock VARCHAR2)
 --</EC-DOC>
IS

BEGIN

NULL;

END new_month;

END ue_bs_instantiate;