CREATE OR REPLACE PACKAGE ue_demurrage IS

/******************************************************************************
** Package        :  ue_demurrage, header part
**
** $Revision: 1.3 $
**
** Purpose        :  Includes user-exit functionality for demurrage
**
** Documentation  :  www.energy-components.com
**
** Created  : 15.05.2007 Kari Sandvik
**
** Modification history:
**
** Date        Whom     Change description:
** -------     ------   -----------------------------------------------
** 21.12.2012  chooysie Add demurrage_type as parameter to findCarrierLaytimeAllowance
*/


  -- Public function and procedure declarations
FUNCTION finDefaultDemurrageRate(p_cargo_no NUMBER, p_demurrage_type VARCHAR2, p_lifting_event VARCHAR2) RETURN NUMBER;
FUNCTION findCarrierLaytimeAllowance(p_cargo_no NUMBER,p_lifting_event VARCHAR2, p_demurrage_type VARCHAR2 DEFAULT NULL)RETURN NUMBER;


END ue_demurrage;