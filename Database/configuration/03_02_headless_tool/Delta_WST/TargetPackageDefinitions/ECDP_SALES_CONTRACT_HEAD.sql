CREATE OR REPLACE PACKAGE EcDp_Sales_Contract IS
/******************************************************************************
** Package        :  EcDp_Sales_Contract, header part
**
** $Revision: 1.1 $
**
** Purpose        :  Encapsulates functionality and values that stem from contract attributes
**
** Documentation  :  www.energy-components.com
**
** Created        : 13.12.2004 Bent Ivar Helland
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------------------------------------------------------------------
** 22.12.2004  BIH   	Initial version (first build / handover to test)
** 03.01.2005  BIH   	Added getMinimumDailyNominationQty and getMaximumDailyNominationQty
** 11.01.2005  BIH   	Added / cleaned up documentation
** 18.10.2005  SKJORSTI added function getActualDCQ
** 19.10.2005  SKJORSTI	Renamed function getDCQ to getRawDCQ
** 06.12.2005  SKJORSTI Updated function getContractYearStartDate. Changed from SCTR_VERSION.CONTRACT_YEAR_START to CONTRACT.START_YEAR (ti3102)
** 06.12.2005  SKJORSTI Updated function getAttributeDaytime. Changed from using table SALES_CONTRACT to use table CONTRACT (ti3102)
********************************************************************/



FUNCTION getRawDCQ(
  p_object_id     VARCHAR2,
  p_contract_day  DATE
)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(getRawDCQ, WNDS, WNPS, RNPS);

--

FUNCTION getActualDCQ(
  p_object_id     VARCHAR2,
  p_contract_day  DATE
)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(getActualDCQ, WNDS, WNPS, RNPS);

PROCEDURE checkRelations(
	p_contract_id	VARCHAR2,
	p_delpt_id		VARCHAR2,
	p_daytime		DATE,
	p_end_date		DATE
);

PROCEDURE validateDCQ(
		p_object_id     VARCHAR2,
  		p_contract_day  DATE,
  		p_adjusted_dcq NUMBER
  		);



END EcDp_Sales_Contract;