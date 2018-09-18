CREATE OR REPLACE PACKAGE EcDp_Currency IS
/****************************************************************
** Package        :  EcDp_Currency
**
** $Revision: 1.8 $
**
** Purpose        :  Finds, generate and aggregate sale forecast data.
**
** Documentation  :  www.energy-components.com
**
** Created  : 16.12.2004  Tor-Erik Hauge
**
** Modification history:
**
** Date       Whom       Change description:
** --------   -----     --------------------------------------
** 16.12.04   HaugeTor   Initial version
** 25.09.06   DN         Modified function getExchangeRate to cope with currency as object and time scope.
** 10.10.06   DN         Migrated convertViaCurrency and GetExRateViaCurrency from EC Revenue.
** 02.05.07   ChongJer   Updated functions with forex_source_id parameter
******************************************************************/

FUNCTION GetCurr100(p_currency_code VARCHAR2, p_daytime DATE)
  RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(GetCurr100, WNDS, WNPS, RNPS);

FUNCTION getExchangeRate(p_daytime            DATE,
                         p_from_currency_code VARCHAR2,
                         p_to_currency_code   VARCHAR2,
                         p_forex_source_id    VARCHAR2,
                         p_time_scope         VARCHAR2 DEFAULT NULL)
  RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getExchangeRate, WNDS, WNPS, RNPS);

FUNCTION convert(p_daytime            DATE,
                 p_amount             NUMBER,
                 p_from_currency_code VARCHAR2,
                 p_to_currency_code   VARCHAR2,
                 p_forex_source_id    VARCHAR2) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(convert, WNDS, WNPS, RNPS);

FUNCTION GetExRowViaCurrency(p_from_curr_code  VARCHAR2,
                             p_to_curr_code    VARCHAR2,
                             p_via_curr_code   VARCHAR2,
                             p_daytime         DATE,
                             p_forex_source_id VARCHAR2,
                             p_duration        VARCHAR2 DEFAULT 'DAILY',
                             p_operator        VARCHAR2 DEFAULT '<=')
  RETURN CURRENCY_EXCHANGE%ROWTYPE;

  FUNCTION GetExRateViaCurrency(p_from_curr_code  VARCHAR2,
                              p_to_curr_code    VARCHAR2,
                              p_via_curr_code   VARCHAR2,
                              p_daytime         DATE,
                              p_forex_source_id VARCHAR2,
                              p_duration        VARCHAR2 DEFAULT 'DAILY',
                              p_operator        VARCHAR2 DEFAULT '<=')
  RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(GetExRateViaCurrency, WNDS, WNPS, RNPS);

FUNCTION GetForexDateViaCurrency(p_book_curr_code  VARCHAR2,
                              p_local_curr_code    VARCHAR2,
                              p_group_curr_code   VARCHAR2,
                              p_daytime         DATE,
                              p_forex_source_id VARCHAR2,
                              p_duration        VARCHAR2 DEFAULT 'DAILY')
  RETURN DATE;
PRAGMA RESTRICT_REFERENCES(GetForexDateViaCurrency, WNDS, WNPS, RNPS);

FUNCTION convertViaCurrency(p_input_val       NUMBER,
                            p_from_curr_code  VARCHAR2,
                            p_to_curr_code    VARCHAR2,
                            p_via_curr_code   VARCHAR2,
                            p_daytime         DATE,
                            p_forex_source_id VARCHAR2,
                            p_duration        VARCHAR2 DEFAULT 'DAILY')
  RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(convertViaCurrency, WNDS, WNPS, RNPS);

END EcDp_Currency;