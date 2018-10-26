CREATE OR REPLACE PACKAGE EcBp_Cargo_Status IS
/**************************************************************************************************
** Package  :  EcBp_Cargo_Status
**
** $Revision: 1.11 $
**
** Purpose  :  This package handles the business logic for changing the cargo status
**
**
**
** General Logic:
**
** Created:     25.10.2004 Kari Sandvik
**
** Modification history:
**
** Date:       Whom: Rev.  Change description:
** ----------  ----- ----  ------------------------------------------------------------------------
** 08.12.2011 leeeewei    ECPD-9104:Cargo Analysis instantiation on insert
** 25.10.2013 leeeewei	  ECPD-6072: Added procedure approvedtoClosed
**************************************************************************************************/

PROCEDURE validate(p_cargo_no VARCHAR2,p_old_cargo_status VARCHAR2,p_new_cargo_status VARCHAR2);

PROCEDURE insertCargoAnalysisItems(p_cargo_no VARCHAR2, p_user VARCHAR2, p_product_id VARCHAR2, p_lifting_event VARCHAR2);

FUNCTION getEcCargoStatus(p_project_cargo_status VARCHAR2) RETURN VARCHAR2;

PROCEDURE updateCargoStatus(p_cargo_no VARCHAR2, p_old_cargo_status VARCHAR2, p_new_cargo_status VARCHAR2, p_user VARCHAR2 DEFAULT NULL);

PROCEDURE approvedToClosed(p_cargo_no VARCHAR2, p_user VARCHAR2);

END EcBp_Cargo_Status;