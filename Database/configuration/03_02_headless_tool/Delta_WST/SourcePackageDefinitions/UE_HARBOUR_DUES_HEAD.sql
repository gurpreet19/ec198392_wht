CREATE OR REPLACE PACKAGE ue_HARBOUR_DUES IS

/******************************************************************************
** Package        :  UE_HARBOUR_DUES, header part
**
** $Revision: 1.2 $
**
** Purpose        :  Includes user-exit functionality for harbour dues screen
**
** Documentation  :  www.energy-components.com
**
** Created  : 17.11.2011 Carsten Claussen
**
** Modification history:
**
** Date        Whom     Change description:
** -------     ------   -----------------------------------------------
*/


-- Public function and procedure declarations
PROCEDURE validate_harbour_dues(p_due_code VARCHAR2, p_due_item_code  VARCHAR2, p_start_date DATE, p_end_date DATE);

END ue_HARBOUR_DUES;