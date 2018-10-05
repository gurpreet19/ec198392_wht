CREATE OR REPLACE PACKAGE BODY ue_Fin_Period IS
/****************************************************************
** Package        :  ue_Fin_Account, body part
**
** $Revision: 1.2 $
**
** Purpose        :  Provide override possibility for project specific logic
**                   connected to opening and closing booking and reporting periods.
**
** Documentation  :  www.energy-components.com
**
** Created  : 22.11.2007  EnergyComponents Team
**
** Modification history:
**
** Version  Date         Whom  Change description:
** -------  ----------   ----- --------------------------------------
** 1.1	    08.06.2012   DRO   Initial version
************************************************************************************************************************************************************/

PROCEDURE UpdatePeriodPreUEE(
 p_daytime DATE,
 p_country_id VARCHAR2,
 p_company_id VARCHAR2,
 p_booking_area_code VARCHAR2,
 p_to_close_date DATE, --date to be closed
 p_user VARCHAR2,
 p_action VARCHAR2, --Closed or Reopen
 p_period_type VARCHAR2, --Booking or Reporting
 p_ind VARCHAR2) IS --Y or N;

BEGIN
  NULL;
END UpdatePeriodPreUEE;

PROCEDURE UpdatePeriodPostUEE(
 p_daytime DATE,
 p_country_id VARCHAR2,
 p_company_id VARCHAR2,
 p_booking_area_code VARCHAR2,
 p_to_close_date DATE, --date to be closed
 p_user VARCHAR2,
 p_action VARCHAR2, --Closed or Reopen
 p_period_type VARCHAR2, --Booking or Reporting
 p_ind VARCHAR2) IS --Y or N;

BEGIN
  NULL;
END UpdatePeriodPostUEE;

PROCEDURE UpdatePeriodJouEntUEE(
 p_daytime DATE,
 p_country_id VARCHAR2,
 p_company_id VARCHAR2,
 p_booking_area_code VARCHAR2,
 p_to_close_date DATE, --date to be closed
 p_user VARCHAR2,
 p_action VARCHAR2, --Closed or Reopen
 p_period_type VARCHAR2, --Booking or Reporting
 p_ind VARCHAR2) IS --Y or N;

BEGIN
  NULL;
END UpdatePeriodJouEntUEE;

PROCEDURE UpdatePeriodQuantityUEE(
 p_daytime DATE,
 p_country_id VARCHAR2,
 p_company_id VARCHAR2,
 p_booking_area_code VARCHAR2,
 p_to_close_date DATE, --date to be closed
 p_user VARCHAR2,
 p_action VARCHAR2, --Closed or Reopen
 p_period_type VARCHAR2, --Booking or Reporting
 p_ind VARCHAR2) IS --Y or N;

BEGIN
  NULL;
END UpdatePeriodQuantityUEE;

PROCEDURE UpdatePeriodInventoryUEE(
 p_daytime DATE,
 p_country_id VARCHAR2,
 p_company_id VARCHAR2,
 p_booking_area_code VARCHAR2,
 p_to_close_date DATE, --date to be closed
 p_user VARCHAR2,
 p_action VARCHAR2, --Closed or Reopen
 p_period_type VARCHAR2, --Booking or Reporting
 p_ind VARCHAR2) IS --Y or N;

BEGIN
  NULL;
END UpdatePeriodInventoryUEE;

PROCEDURE UpdatePeriodSaleUEE(
 p_daytime DATE,
 p_country_id VARCHAR2,
 p_company_id VARCHAR2,
 p_booking_area_code VARCHAR2,
 p_to_close_date DATE, --date to be closed
 p_user VARCHAR2,
 p_action VARCHAR2, --Closed or Reopen
 p_period_type VARCHAR2, --Booking or Reporting
 p_ind VARCHAR2) IS --Y or N;

BEGIN
  NULL;
END UpdatePeriodSaleUEE;

PROCEDURE UpdatePeriodPurchaseUEE(
 p_daytime DATE,
 p_country_id VARCHAR2,
 p_company_id VARCHAR2,
 p_booking_area_code VARCHAR2,
 p_to_close_date DATE, --date to be closed
 p_user VARCHAR2,
 p_action VARCHAR2, --Closed or Reopen
 p_period_type VARCHAR2, --Booking or Reporting
 p_ind VARCHAR2) IS --Y or N;

BEGIN
  NULL;
END UpdatePeriodPurchaseUEE;

PROCEDURE UpdatePeriodTaIncomeUEE(
 p_daytime DATE,
 p_country_id VARCHAR2,
 p_company_id VARCHAR2,
 p_booking_area_code VARCHAR2,
 p_to_close_date DATE, --date to be closed
 p_user VARCHAR2,
 p_action VARCHAR2, --Closed or Reopen
 p_period_type VARCHAR2, --Booking or Reporting
 p_ind VARCHAR2) IS --Y or N;

BEGIN
  NULL;
END UpdatePeriodTaIncomeUEE;

PROCEDURE UpdatePeriodTaCostUEE(
 p_daytime DATE,
 p_country_id VARCHAR2,
 p_company_id VARCHAR2,
 p_booking_area_code VARCHAR2,
 p_to_close_date DATE, --date to be closed
 p_user VARCHAR2,
 p_action VARCHAR2, --Closed or Reopen
 p_period_type VARCHAR2, --Booking or Reporting
 p_ind VARCHAR2) IS --Y or N;

BEGIN
  NULL;
END UpdatePeriodTaCostUEE;


END ue_Fin_Period;