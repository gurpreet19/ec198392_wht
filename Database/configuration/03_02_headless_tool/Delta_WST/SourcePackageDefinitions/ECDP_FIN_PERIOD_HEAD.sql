CREATE OR REPLACE PACKAGE EcDp_Fin_Period IS
/****************************************************************
** Package        :  EcDp_Fin_Period, header part
**
** $Revision: 1.23 $
**
** Purpose        :  Provide special functions on Financials Periods
**
** Documentation  :  www.energy-components.com
**
** Created  : 27.11.2005 Trond-Arne Brattli
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- --------------------------------------
*****************************************************************/

PROCEDURE OpenPeriod(
   p_period_type VARCHAR2, -- BOOKING or REPORTING
   p_daytime DATE, -- period
   p_user VARCHAR2
) ;

PROCEDURE ClosePeriod(
   p_period_type VARCHAR2, -- BOOKING or REPORTING
   p_daytime DATE, -- period
   p_user VARCHAR2,
   p_closing_time DATE DEFAULT Ecdp_Timestamp.getCurrentSysdate
);

FUNCTION GetCurrOpenPeriod( --This function is no longer in used
   p_daytime   DATE DEFAULT Ecdp_Timestamp.getCurrentSysdate,
   p_period_type VARCHAR2 DEFAULT 'BOOKING'
)

RETURN DATE;

PROCEDURE instantiateMissingPeriods(
    p_daytime                            DATE,
    p_user                               VARCHAR2);

PROCEDURE instantiatePeriod
 (p_daytime DATE, p_user VARCHAR2, p_company_id VARCHAR2 DEFAULT NULL);

PROCEDURE instantiatePeriodForCompany(p_user VARCHAR2, p_company_id VARCHAR2);

FUNCTION getLatestFullyClosedPeriod(p_booking_area_code VARCHAR2, p_period_type VARCHAR2)
    RETURN DATE;

FUNCTION getClosedPeriodStatusAll
 (p_daytime DATE, p_country_id VARCHAR2, p_company_id VARCHAR2, p_period_type VARCHAR2)
RETURN VARCHAR2;

FUNCTION getClosedPeriodStatus
 (p_daytime DATE)
RETURN VARCHAR2;

PROCEDURE updatePeriod(
 p_daytime DATE,
 p_country_id VARCHAR2,
 p_company_id VARCHAR2,
 p_booking_area_code VARCHAR2,
 p_to_close_date DATE, --date to be closed
 p_user VARCHAR2,
 p_action VARCHAR2, --Closed or Reopen
 p_period_type VARCHAR2, --Booking or Reporting
 p_ind VARCHAR2); --Y or N

PROCEDURE updatePeriodAll(
 p_daytime DATE,
 p_country_id VARCHAR2,
 p_company_id VARCHAR2,
 p_user VARCHAR2,
 p_action VARCHAR2, --Closed or Reopen
 p_period_type VARCHAR2,
 p_ind VARCHAR2); --Booking or Reporting

FUNCTION getCurrentOpenPeriod(
 p_country_id VARCHAR2,
 p_company_id VARCHAR2,
 p_booking_area_code VARCHAR2,
 p_period_type VARCHAR2 DEFAULT 'BOOKING',
 p_doc_key VARCHAR2 DEFAULT NULL,
 p_doc_date DATE DEFAULT NULL
)
RETURN DATE;

FUNCTION getCurrOpenPeriodByObject(
 p_object_id VARCHAR2,
 p_daytime DATE,
 p_booking_area_code VARCHAR2,
 p_period_type VARCHAR2 DEFAULT 'BOOKING',
 p_doc_key VARCHAR2 DEFAULT NULL,
 p_doc_date DATE DEFAULT NULL)
RETURN DATE;

FUNCTION getCompanyIdByAreaCode(
 p_object_id VARCHAR2,
 p_daytime DATE,
 p_booking_area_code VARCHAR2
)
RETURN VARCHAR2;

FUNCTION chkPeriodExistByObject(
 p_object_id VARCHAR2,
 p_daytime DATE,
 p_document_date DATE,
 p_booking_area_code VARCHAR2,
 p_period_type VARCHAR2 DEFAULT 'BOOKING')
RETURN DATE;

END EcDp_Fin_Period;