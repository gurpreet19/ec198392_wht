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
** Created:     05.11.2004 Egil Ølberg
**
** Modification history:
**
** Date:       Whom: Rev.  Change description:
** ----------  ----- ----  ------------------------------------------------------------------------
** 01.07.2009  lauuufus 10.1  Update function findCommencedLaytime, findCompletedLaytime and findLaytime to support multiple Run No.
**************************************************************************************************/
FUNCTION findStartLoadingRange(P_cargo_no NUMBER, p_lifting_event VARCHAR2) RETURN DATE;
PRAGMA RESTRICT_REFERENCES (findStartLoadingRange, RNPS, WNPS,WNDS);

FUNCTION findCommencedLaytime (p_cargo_no NUMBER, p_demurrage_type VARCHAR2, p_activity VARCHAR2, p_boundary VARCHAR2, p_lifting_event VARCHAR2, p_laytime_start_run_no NUMBER DEFAULT NULL) RETURN DATE;
PRAGMA RESTRICT_REFERENCES (findCommencedLaytime, RNPS, WNPS,WNDS);

FUNCTION findCompletedLaytime (p_cargo_no NUMBER, p_demurrage_type VARCHAR2, p_activity VARCHAR2, p_boundary VARCHAR2, p_lifting_event VARCHAR2, p_laytime_end_run_no NUMBER DEFAULT NULL) RETURN DATE;
PRAGMA RESTRICT_REFERENCES (findCompletedLaytime, RNPS, WNPS,WNDS);

FUNCTION findLaytime(p_cargo_no NUMBER, p_demurrage_type VARCHAR2, p_start_activity VARCHAR2, p_start_boundary VARCHAR2,p_end_activity VARCHAR2, p_end_boundary VARCHAR2, p_lifting_event VARCHAR2, p_laytime_end_run_no NUMBER DEFAULT NULL, p_laytime_start_run_no NUMBER DEFAULT NULL) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findLaytime, RNPS, WNPS,WNDS);

FUNCTION findCarrierLaytimeAllowance(P_cargo_no NUMBER, p_lifting_event VARCHAR2) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findCarrierLaytimeAllowance, RNPS, WNPS,WNDS);

FUNCTION findDelayFromTimesheet(p_cargo_no NUMBER, p_demurrage_type VARCHAR2, p_lifting_event VARCHAR2) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findDelayFromTimesheet, RNPS, WNPS,WNDS);

FUNCTION findDemurrageTime (p_cargo_no NUMBER, p_demurrage_type VARCHAR2, p_lifting_event VARCHAR2) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findDemurrageTime, RNPS, WNPS,WNDS);

FUNCTION findCalculatedClaim(p_cargo_no NUMBER, p_demurrage_type VARCHAR2, p_lifting_event VARCHAR2) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findCalculatedClaim, RNPS, WNPS,WNDS);

END EcBp_Demurrage;