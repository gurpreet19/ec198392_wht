CREATE OR REPLACE PACKAGE EcBp_Transaction IS
 /****************************************************************
** Package        :  EcBp_Transaction
**
** $Revision: 1.6 $
**
** Purpose        :   Functionality for handling transactions between accounts
**
**
**
**
** Documentation  :  www.energy-components.com
**
** Created  : 30.03.2001  Bj?Ovin Wivestad
**
** Modification history:
**
** Date       Whom   Change description:
** -------    ------ ----- --------------------------------------
** 31.08.2004 DN     Removed sum_all_export_transactions, normalize_accounts,sum_nom_transactions, update_transactions, update_all.
**                   Added get_account_no from EcBp_Transaction.
** 02.09.2004 KSN	   Removed function that where not used
** 08.09.2004 KSN	   Added get_transaction_account.
** 08.10.2004 DN     Removed lifting agreement functionality.
*****************************************************************/
-- Table types
TYPE tab_parcel_no IS TABLE OF parcel_nomination.parcel_no%TYPE INDEX BY BINARY_INTEGER;
TYPE tab_devet IS TABLE OF parcel_nomination.grs_vol_nominated%TYPE INDEX BY BINARY_INTEGER;

/*****************************************************************/
PROCEDURE transaction(p_company_id     IN   VARCHAR2,
                      p_storage_id   IN   VARCHAR2,
                      p_daytime        IN   DATE,
                      p_parcel_no      IN   NUMBER,
                      p_batch_no       IN   NUMBER,
                      p_debet          IN   NUMBER,
                      p_transaction_type  IN VARCHAR2,
                      p_status            OUT NUMBER);
/*****************************************************************/
PROCEDURE insert_transaction(
                             p_company_id   IN VARCHAR2,
                             p_storage_id IN VARCHAR2,
                             p_daytime      IN DATE,
                             p_parcel_no    IN NUMBER,
                             p_batch_no     IN NUMBER,
                             p_debet        IN NUMBER,
                             p_transaction_type IN VARCHAR2,
                             p_status           OUT NUMBER);
/*****************************************************************/
PROCEDURE update_transaction(p_company_id       IN VARCHAR2,
                             p_storage_id     IN VARCHAR2,
                             p_daytime          IN DATE,
                             p_parcel_no        IN NUMBER,
                             p_batch_no         IN NUMBER,
                             p_debet            IN NUMBER,
                             p_transaction_type IN VARCHAR2,
                             p_status           OUT NUMBER);
/*****************************************************************/
PROCEDURE get_next_id(p_tablename IN  VARCHAR2,
                      p_max_id    OUT NUMBER);
/*****************************************************************/
PROCEDURE delete_parcel_trans(
                            p_storage_id     IN VARCHAR2,
                            p_parcel_no             IN NUMBER,
                            p_status           OUT VARCHAR2);
/*****************************************************************/
PROCEDURE delete_transaction(p_storage_id     IN VARCHAR2,
                             p_status           OUT VARCHAR2);
/*****************************************************************/
FUNCTION get_transaction_account(p_storage_id VARCHAR2,
								 p_parcel_no NUMBER,
								 p_account_no VARCHAR2) RETURN NUMBER;

END EcBp_Transaction;