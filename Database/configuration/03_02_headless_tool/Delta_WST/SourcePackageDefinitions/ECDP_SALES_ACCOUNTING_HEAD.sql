CREATE OR REPLACE PACKAGE EcDp_Sales_Accounting IS
/******************************************************************************
** Package        :  EcDp_Sales_Accounting, head part
**
** $Revision: 1.1 $
**
** Purpose        :  Account processing and approval
**
** Documentation  :  www.energy-components.com
**
** Created  : 13.12.2004 Bent Ivar Helland
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------------------------------------------------------------------
** 22.12.2004  BIH   	Initial version (first build / handover to test)
** 11.01.2005  BIH   	Added / cleaned up documentation
** 11.03.2005  DN    	Redefined getAccountAttributeText with new name getAccountAttributeVersion. Added getAccountName.
** 06.12.2005  SKJORSTI	Removed function getAccountAttributeVersion (ti3106).
** 06.12.2005  SKJORSTI	Updated function getAccountCalcOrder to use new package (ti3106).
** 06.12.2005  SKJORSTI	Updated cursor c_accounts to use new table contract_account (ti3106).
** 06.12.2005  SKJORSTI	Updated functinon processDailyAccounts. Updated reference to cursor c_accounts and to function EcDp_Sales_Acc_Price_Concept (ti3106).
** 07.12.2005  SKJORSTI	Removed function getAccountName. As no version table exists anymore, PK is enough as argument for this property -> using ec_package instead (ti3106)
** 07.12.2005  SKJORSTI	Updated function updateAccountStatus; deemed_qty->vol_qty, added account_code argument to function and modified statements accordingly (ti3106).
** 07.12.2005  SKJORSTI	Updated function processDailyAccounts; added argument account_code to call to updateAccountStatus (ti3106).
** 07.12.2005  SKJORSTI	Updated function isAccountEditable; removed daytime argument. Replaced call to function getAccountAttributeVersion with call to ec_contract_account. Argument usage should be reconsidered (ti3106)
** 07.12.2005  SKJORSTI	Updated function getNumberOfApprovedAccounts. Rewritten join between cntr_acc_period_status and contract_account. Status record still compared towards column in cntr_acc_period_status (ti3106)
** 07.12.2005  SKJORSTI	Updated function getNumberOfProcessedAccounts. Rewritten join between cntr_acc_period_status and contract_account (ti3106)
** 07.12.2005  SKJORSTI	Updated function approveYearlyAccounts. Rewritten join between cntr_acc_period_status and contract_account. Date is found in table contract (ti3106)
** 07.12.2005  SKJORSTI	Updated function approveMonthlyAccounts. Rewritten join between cntr_acc_period_status and contract_account. Date is found in table contract (ti3106)
** 16.12.2005 	eideekri	Updated function processDailyAccounts. Rewritten for the change from del_qty into vol_qty, mass_qty and energy_qty.
** 01.02.2006  skjorsti Updated procedure processMonthlyAccounts and  processYearlyAccounts. Added contract-date validation to cursor c_accounts. (TD 5520/5546/5499)
**************************************************************************************************************************************************************************************************/


PROCEDURE processDailyAccounts(
  p_contract_id  VARCHAR2,
  p_contract_day       DATE,
  p_username           VARCHAR2,
  p_accessLevel        INTEGER
);

--

PROCEDURE processMonthlyAccounts(
  p_contract_id  VARCHAR2,
  p_contract_month     DATE,
  p_username           VARCHAR2,
  p_accessLevel        INTEGER
);

--

PROCEDURE processYearlyAccounts(
  p_contract_id  VARCHAR2,
  p_contract_year      DATE,
  p_username           VARCHAR2,
  p_accessLevel        INTEGER
);

--

PROCEDURE approveMonthlyAccounts(
  p_contract_id  VARCHAR2,
  p_contract_month     DATE,
  p_username           VARCHAR2,
  p_accessLevel        INTEGER
);

--

PROCEDURE approveYearlyAccounts(
  p_contract_id  VARCHAR2,
  p_contract_year      DATE,
  p_username           VARCHAR2,
  p_accessLevel        INTEGER
);

--

FUNCTION getNumberOfProcessedAccounts(
  p_contract_id  VARCHAR2,
  p_daytime            DATE,
  p_time_span          VARCHAR2
)
RETURN INTEGER;

--

FUNCTION getNumberOfApprovedAccounts(
  p_contract_id  VARCHAR2,
  p_daytime            DATE,
  p_time_span          VARCHAR2
)
RETURN INTEGER;

--

FUNCTION getAccountCalcOrder(
   p_category     VARCHAR2
)
RETURN NUMBER;

--

FUNCTION getHourlyOffSpecFraction(
  p_contract_id  VARCHAR2,
  p_delivery_point_id  VARCHAR2,
  p_daytime    DATE
)
RETURN NUMBER;

--

FUNCTION getDailyOffSpecFraction(
  p_contract_id  VARCHAR2,
  p_delivery_point_id  VARCHAR2,
  p_contract_day       DATE
)
RETURN NUMBER;

--

FUNCTION isAccountEditable(
	p_object_id		VARCHAR2,
   p_account_code   VARCHAR2,
   p_time_span    	VARCHAR2
)
RETURN VARCHAR2;

--

PROCEDURE updateAccountStatus(
  p_account_code        VARCHAR2,
  p_object_id			VARCHAR2,
  p_daytime            	DATE,
  p_time_span          	VARCHAR2,
  p_qty                	NUMBER,
  p_total_price        	NUMBER,
  p_username           	VARCHAR2
);

--

END EcDp_Sales_Accounting;