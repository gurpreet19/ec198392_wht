CREATE OR REPLACE PACKAGE EcBp_Entitlement IS
/****************************************************************
** Package        :  EcBp_entitlement
**
** $Revision: 1.7 $
**
** Purpose        :  This package is responsible for calculating the availability
**                   for each equity holder, third party and contracted lifter
**                   associated with a terminal or production facility.
**
**
** Documentation  :  www.energy-components.com
**
** Created  : 20.03.2001  Bjørn-Ovin Wivestad
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- --------------------------------------
** 1.0      110701   DN    Moved TYPE definition to body. Changed parameter interface
**                         in function find_largest_entitlement
**				  240901   BOW   Rewrote CALC_PRODUTION to match database fix with new column in ACCOUNT -> ACCOUNT_CATEGORY.
** 1.0      190302   DN    Removed find_last_stor_date, get_stor_vol and generate_lifting_program. These function should be redesigned using new storage tables.
**          060203   HNE   Added parameter p_daytime in call to find_start_date
** 		     	080904	KSN	Cceanup in release 80
**          081004   DN    Removed function calc_production_contract and find_day_share.
**          250211  leongwen ECPD-16917 Fluid Type on Equity Share should be exposed in business logics
*****************************************************************/

/* Globally defined tables*/
/*TYPE tab_balance_ind IS TABLE OF lift_agreement_account.balance_ind%TYPE INDEX BY BINARY_INTEGER;
TYPE tab_licence_prod IS TABLE OF terminal_receipt.grs_vol%TYPE INDEX BY BINARY_INTEGER;
TYPE tab_companies IS TABLE OF account.company_no%TYPE INDEX BY BINARY_INTEGER;
TYPE tab_licence_no IS TABLE OF licence.licence_no%TYPE INDEX BY BINARY_INTEGER;
TYPE tab_storage_code IS TABLE OF account.storage_code%TYPE INDEX BY BINARY_INTEGER;
TYPE tab_terminal_code IS TABLE OF account.terminal_code%TYPE INDEX BY BINARY_INTEGER;
TYPE tab_account_no IS TABLE OF account.account_no%TYPE INDEX BY BINARY_INTEGER;
TYPE tab_shipper IS TABLE OF commercial_area.shipper%TYPE INDEX BY BINARY_INTEGER;
TYPE tab_eco_share IS TABLE OF equity_share.eco_share%TYPE INDEX BY BINARY_INTEGER;
TYPE tab_prod_share IS TABLE OF terminal_receipt.grs_vol%TYPE INDEX BY BINARY_INTEGER;
TYPE tab_date IS TABLE OF acc_transaction.daytime%TYPE INDEX BY BINARY_INTEGER;
TYPE tab_transaction_no IS TABLE OF acc_transaction.transaction_no%TYPE INDEX BY BINARY_INTEGER;
TYPE tab_lifted_vol IS TABLE OF parcel_load.grs_vol_bbls%TYPE INDEX BY BINARY_INTEGER;
TYPE tab_account_balance IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE tab_agreement_code IS TABLE OF lifting_agreement.agreement_code%TYPE INDEX BY BINARY_INTEGER;
TYPE tab_index	IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE tab_split	IS TABLE OF lift_agreement_account.fixed_pct%TYPE INDEX BY BINARY_INTEGER;
*/
/*Functions and procedures*/

FUNCTION calc_production(p_storage_id   VARCHAR2,
                         p_shipper        VARCHAR2,
                         p_company_id     VARCHAR2,
                         p_account_no     VARCHAR2,
                         p_prod_plan      VARCHAR2,
                         p_from_day       DATE,
                         p_to_day         DATE,
                         p_phase          VARCHAR2) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(calc_production,WNDS, WNPS, RNPS);

/****************************************************/
FUNCTION calc_day_balance(p_storage_id   VARCHAR2,
                          p_shipper        VARCHAR2,
                          p_company_id     VARCHAR2,
                          p_account_no     VARCHAR2,
                          p_daytime        DATE,
                          p_prod_plan      VARCHAR2,
                          p_phase          VARCHAR2) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(calc_day_balance,WNDS, WNPS, RNPS);

/******************************************************/
FUNCTION get_lifted_volume(p_account_no    VARCHAR2,
                           p_storage_id  VARCHAR2,
                           p_from_day      DATE,
                           p_to_day        DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(get_lifted_volume, WNDS, WNPS, RNPS);

/******************************************************/
FUNCTION find_start_date(p_account_no VARCHAR2, p_daytime DATE) RETURN DATE;
PRAGMA RESTRICT_REFERENCES(find_start_date, WNDS, WNPS, RNPS);

/****************************************************/
FUNCTION calc_production_prod(p_storage_id   VARCHAR2,
                              p_shipper        VARCHAR2,
                              p_company_id     VARCHAR2,
                              p_plan           VARCHAR2,
                              p_from_day       DATE,
                              p_to_day         DATE,
                              p_phase          VARCHAR2) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(calc_production_prod,WNDS, WNPS, RNPS);
/******************************************************/
FUNCTION find_day_eco_share(p_shipper VARCHAR2,
							p_company_id VARCHAR2,
							p_day DATE,
              p_phase VARCHAR2) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(find_day_eco_share, WNDS, WNPS, RNPS);

/*****************************************************************/
FUNCTION get_production_by_day(p_storage_id   VARCHAR2,
                               p_shipper        VARCHAR2,
                               p_plan           VARCHAR2,
                               p_day            DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(get_production_by_day,WNDS, WNPS, RNPS);

/******************************************************/
FUNCTION real_prod_day(p_storage_id VARCHAR2,
         p_shipper VARCHAR2,
         p_daytime DATE)
         RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (real_prod_day, WNDS, WNPS, RNPS);

/******************************************************/
FUNCTION forcast_prod_day(
         p_storage_id VARCHAR2,
         p_shipper VARCHAR2,
         p_plan    VARCHAR2,
         p_daytime DATE)
         RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (forcast_prod_day, WNDS, WNPS, RNPS);

/******************************************************/
PROCEDURE Write_account_mth_balance (p_storage_id VARCHAR2,
                                     p_daytime DATE,
                                     p_phase VARCHAR2);
/******************************************************/

END EcBp_Entitlement;