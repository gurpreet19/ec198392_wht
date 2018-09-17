CREATE OR REPLACE PACKAGE EcBp_Contract_Nomination IS
/******************************************************************************
** Package        :  EcBp_Contract_Nomination, head part
**
** $Revision: 1.8 $
**
** Purpose        :  Find and work with nomination data
**
** Documentation  :  www.energy-components.com
**
** Created        :  08.08.2005 Narinder Kaur Man Singh
**
** Modification history:
**
** Date        Whom           Change description:
** --------    --------       -----------------------------------------------------------------------------------------------
** 11.04.06    eikebeir       Added copyLatestNoms and generateNomHours
** 11.06.10    lauuufus       Added procedure for overlapping period validation.
** 28.01.11    lauuufus  ECPD-16765 Added procedure for overlapping period validation for Nomination Point Connection.
********************************************************************/

FUNCTION getRenomQty(
  p_contract_id   VARCHAR2,
  p_delivery_point_id   VARCHAR2,
  p_daytime		DATE,
  p_renom_qty	NUMBER,
  p_next_daytime DATE DEFAULT NULL
)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getRenomQty, WNDS, WNPS, RNPS);

PROCEDURE checkIfPcListOverlaps(p_object_id VARCHAR2,p_profit_centre_id VARCHAR2, p_daytime DATE, p_end_date DATE);

PROCEDURE checkProfitCentreOverlaps(p_object_id VARCHAR2,p_profit_centre_id VARCHAR2, p_company_id VARCHAR2, p_daytime DATE, p_end_date DATE);

PROCEDURE checkNomPntOverlaps(p_object_id VARCHAR2,p_nompnt_id VARCHAR2, p_daytime DATE, p_end_date DATE);

END EcBp_Contract_Nomination;