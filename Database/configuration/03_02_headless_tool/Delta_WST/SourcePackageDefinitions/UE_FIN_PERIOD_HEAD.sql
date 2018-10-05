CREATE OR REPLACE PACKAGE ue_Fin_Period IS
/****************************************************************
**
** NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE
** NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE
** Enable this User Exit by setting variable below "isUserExitEnabled" = 'TRUE'
** NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE
** NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE
**
** Package        :  EcDp_Fin_Account, header part
**
** $Revision: 1.2 $
**
** Purpose        :  Provide override possibility for project specific logic
**                   connected to opening and closing booking and reporting periods.
** Documentation  :  www.energy-components.com
**
** Created  : 08.06.2012  EnergyComponents Team
**
** Modification history:
**
** Version  Date         Whom  Change description:
** -------  ----------   ----- --------------------------------------
** 1.1	    08.06.2012   DRO   Initial version
*****************************************************************/
isUpdatePeriodPreUEE       VARCHAR2(32) := 'FALSE';
isUpdatePeriodPostUEE      VARCHAR2(32) := 'FALSE';
isUpdatePeriodJouEntUEE    VARCHAR2(32) := 'FALSE'; -- JOU_ENT
isUpdatePeriodQuantityUEE  VARCHAR2(32) := 'FALSE'; -- QUANTITIES
isUpdatePeriodInventoryUEE VARCHAR2(32) := 'FALSE'; -- INVENTORY
isUpdatePeriodSaleUEE      VARCHAR2(32) := 'FALSE'; -- SALE
isUpdatePeriodPurchaseUEE  VARCHAR2(32) := 'FALSE'; -- PURCHASE
isUpdatePeriodTaIncomeUEE  VARCHAR2(32) := 'FALSE'; -- TA_INCOME
isUpdatePeriodTaCostUEE    VARCHAR2(32) := 'FALSE'; -- TA_COST

PROCEDURE UpdatePeriodPreUEE(
 p_daytime DATE,
 p_country_id VARCHAR2,
 p_company_id VARCHAR2,
 p_booking_area_code VARCHAR2,
 p_to_close_date DATE, --date to be closed
 p_user VARCHAR2,
 p_action VARCHAR2, --Closed or Reopen
 p_period_type VARCHAR2, --Booking or Reporting
 p_ind VARCHAR2); --Y or N;

PROCEDURE UpdatePeriodPostUEE(
 p_daytime DATE,
 p_country_id VARCHAR2,
 p_company_id VARCHAR2,
 p_booking_area_code VARCHAR2,
 p_to_close_date DATE, --date to be closed
 p_user VARCHAR2,
 p_action VARCHAR2, --Closed or Reopen
 p_period_type VARCHAR2, --Booking or Reporting
 p_ind VARCHAR2); --Y or N;

PROCEDURE UpdatePeriodJouEntUEE(
 p_daytime DATE,
 p_country_id VARCHAR2,
 p_company_id VARCHAR2,
 p_booking_area_code VARCHAR2,
 p_to_close_date DATE, --date to be closed
 p_user VARCHAR2,
 p_action VARCHAR2, --Closed or Reopen
 p_period_type VARCHAR2, --Booking or Reporting
 p_ind VARCHAR2); --Y or N;

PROCEDURE UpdatePeriodQuantityUEE(
 p_daytime DATE,
 p_country_id VARCHAR2,
 p_company_id VARCHAR2,
 p_booking_area_code VARCHAR2,
 p_to_close_date DATE, --date to be closed
 p_user VARCHAR2,
 p_action VARCHAR2, --Closed or Reopen
 p_period_type VARCHAR2, --Booking or Reporting
 p_ind VARCHAR2); --Y or N;

PROCEDURE UpdatePeriodInventoryUEE(
 p_daytime DATE,
 p_country_id VARCHAR2,
 p_company_id VARCHAR2,
 p_booking_area_code VARCHAR2,
 p_to_close_date DATE, --date to be closed
 p_user VARCHAR2,
 p_action VARCHAR2, --Closed or Reopen
 p_period_type VARCHAR2, --Booking or Reporting
 p_ind VARCHAR2); --Y or N;

PROCEDURE UpdatePeriodSaleUEE(
 p_daytime DATE,
 p_country_id VARCHAR2,
 p_company_id VARCHAR2,
 p_booking_area_code VARCHAR2,
 p_to_close_date DATE, --date to be closed
 p_user VARCHAR2,
 p_action VARCHAR2, --Closed or Reopen
 p_period_type VARCHAR2, --Booking or Reporting
 p_ind VARCHAR2); --Y or N;

PROCEDURE UpdatePeriodPurchaseUEE(
 p_daytime DATE,
 p_country_id VARCHAR2,
 p_company_id VARCHAR2,
 p_booking_area_code VARCHAR2,
 p_to_close_date DATE, --date to be closed
 p_user VARCHAR2,
 p_action VARCHAR2, --Closed or Reopen
 p_period_type VARCHAR2, --Booking or Reporting
 p_ind VARCHAR2); --Y or N;

PROCEDURE UpdatePeriodTaIncomeUEE(
 p_daytime DATE,
 p_country_id VARCHAR2,
 p_company_id VARCHAR2,
 p_booking_area_code VARCHAR2,
 p_to_close_date DATE, --date to be closed
 p_user VARCHAR2,
 p_action VARCHAR2, --Closed or Reopen
 p_period_type VARCHAR2, --Booking or Reporting
 p_ind VARCHAR2); --Y or N

PROCEDURE UpdatePeriodTaCostUEE(
 p_daytime DATE,
 p_country_id VARCHAR2,
 p_company_id VARCHAR2,
 p_booking_area_code VARCHAR2,
 p_to_close_date DATE, --date to be closed
 p_user VARCHAR2,
 p_action VARCHAR2, --Closed or Reopen
 p_period_type VARCHAR2, --Booking or Reporting
 p_ind VARCHAR2); --Y or N;



END ue_Fin_Period;