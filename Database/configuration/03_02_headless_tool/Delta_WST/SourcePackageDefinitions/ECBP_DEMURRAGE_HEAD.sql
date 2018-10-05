CREATE OR REPLACE PACKAGE EcBp_Demurrage IS
/**************************************************************************************************
** Package  :  EcBp_Demurrage
**
** $Revision: 1.7 $
**
** Purpose  :  This package handles the business logic for demurrages
**
**
**
** General Logic:
**
** Created:     05.11.2004 Egil ?berg
**
** Modification history:
**
** Date:       Whom: Rev.  Change description:
** ----------  ----- ----  ------------------------------------------------------------------------
** 01.07.2009  lauuufus 10.1  Update function findCommencedLaytime, findCompletedLaytime and findLaytime to support multiple Run No.
**************************************************************************************************/
FUNCTION findStartLoadingRange(P_cargo_no NUMBER, p_lifting_event VARCHAR2) RETURN DATE;

FUNCTION findCommencedLaytime (p_cargo_no NUMBER, p_demurrage_type VARCHAR2, p_activity VARCHAR2, p_boundary VARCHAR2, p_lifting_event VARCHAR2, p_laytime_start_run_no NUMBER DEFAULT NULL) RETURN DATE;

FUNCTION findCompletedLaytime (p_cargo_no NUMBER, p_demurrage_type VARCHAR2, p_activity VARCHAR2, p_boundary VARCHAR2, p_lifting_event VARCHAR2, p_laytime_end_run_no NUMBER DEFAULT NULL) RETURN DATE;

FUNCTION findLaytime(p_cargo_no NUMBER, p_demurrage_type VARCHAR2, p_start_activity VARCHAR2, p_start_boundary VARCHAR2,p_end_activity VARCHAR2, p_end_boundary VARCHAR2, p_lifting_event VARCHAR2, p_laytime_end_run_no NUMBER DEFAULT NULL, p_laytime_start_run_no NUMBER DEFAULT NULL) RETURN NUMBER;

FUNCTION findCarrierLaytimeAllowance(P_cargo_no NUMBER, p_lifting_event VARCHAR2) RETURN NUMBER;

FUNCTION findDelayFromTimesheet(p_cargo_no NUMBER, p_demurrage_type VARCHAR2, p_lifting_event VARCHAR2) RETURN NUMBER;

FUNCTION findDemurrageTime (p_cargo_no NUMBER, p_demurrage_type VARCHAR2, p_lifting_event VARCHAR2) RETURN NUMBER;

FUNCTION findCalculatedClaim(p_cargo_no NUMBER, p_demurrage_type VARCHAR2, p_lifting_event VARCHAR2) RETURN NUMBER;

END EcBp_Demurrage;