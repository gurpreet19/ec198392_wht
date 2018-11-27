CREATE OR REPLACE PACKAGE BODY EcBp_Transaction IS
/****************************************************************
** Package        :  EcBp_Transaction_body
**
** $Revision: 1.5 $
**
** Purpose        :   Functionality for handling transactions between accounts
**
**
**
**
** Documentation  :  www.energy-components.com
**
** Created  : 30.03.2001  Bjørn-Ovin Wivestad
**
** Modification history:
**
** Date       Whom  Change description:
** ------     ----- --------------------------------------
** 31.08.2004 DN    Removed sysnam. Removed function sum_all_export_transactions, normalize_accounts sum_nom_transactions,
**                  update_transactions, update_all.
** 02.09.2004 KSN	  Removed function that where not used
** 08.10.2004 DN    Removed lifting agreement functionality.
*****************************************************************/
PROCEDURE transaction(p_company_id     IN   VARCHAR2,
                      p_storage_id   IN   VARCHAR2,
                      p_daytime        IN   DATE,
                      p_parcel_no      IN   NUMBER,
                      p_batch_no       IN   NUMBER,
                      p_debet          IN   NUMBER,
                      p_transaction_type  IN VARCHAR2,
                      p_status            OUT NUMBER)
IS
CURSOR c_find_transaction(cp_transaction_type VARCHAR2)
IS
SELECT COUNT(transaction_no)
FROM acc_transaction
WHERE parcel_no = p_parcel_no
AND receipt_no = p_batch_no
AND transaction_type = cp_transaction_type
AND tran_status = 'A';

/*
This cursor traverses all lifting transactions
*/
CURSOR c_trans_update_info
IS
SELECT transaction_type
FROM acc_transaction
WHERE parcel_no = p_parcel_no
AND receipt_no = p_batch_no
AND transaction_type IN ('PLANNED','LIFTED')
AND tran_status = 'A';

ln_count      					NUMBER := 0;
ll_status     					NUMBER := 0;
lv_trans_type						VARCHAR2(32);

BEGIN
  -- Decide if this is an update or an insert
  IF p_transaction_type = 'UPDATE' THEN
	  FOR curTransInfo IN c_trans_update_info LOOP
	     lv_trans_type := curTransInfo.transaction_type;
		  IF lv_trans_type IS NULL THEN
		    insert_transaction(p_company_id, p_storage_id, p_daytime, p_parcel_no, p_batch_no, p_debet, 'PLANNED', ll_status);
		  ELSE
		    update_transaction(p_company_id, p_storage_id, p_daytime, p_parcel_no, p_batch_no, p_debet, lv_trans_type, ll_status);
		  END IF;
     END LOOP;
	ELSE
	  OPEN c_find_transaction(p_transaction_type);
	  FETCH c_find_transaction INTO ln_count;
	  CLOSE c_find_transaction;

	  IF ln_count = 0 AND p_debet >= 0 THEN
	    insert_transaction(p_company_id, p_storage_id, p_daytime, p_parcel_no, p_batch_no, p_debet, p_transaction_type, ll_status);
	  ELSE
	    update_transaction(p_company_id, p_storage_id, p_daytime, p_parcel_no, p_batch_no, p_debet, p_transaction_type, ll_status);
	  END IF;
  END IF;

  p_status := ll_status;

END transaction;
---------------------------------------------------------------------
-- Insert new transaction
----------------------------------------------------------------------
PROCEDURE insert_transaction(p_company_id   IN VARCHAR2,
                             p_storage_id   IN VARCHAR2,
                             p_daytime      IN DATE,
                             p_parcel_no    IN NUMBER,
                             p_batch_no     IN NUMBER,
                             p_debet        IN NUMBER,
                             p_transaction_type IN VARCHAR2,
                             p_status           OUT NUMBER)
IS

CURSOR c_account_info(cp_company_id VARCHAR2, cp_storage_id VARCHAR2)
IS
SELECT account_no
FROM account
WHERE company_id = cp_company_id
AND storage_id = cp_storage_id;

-- Local variables
lv_account_no       VARCHAR2(16);
lv_transaction_no   VARCHAR2(16);
lv_transaction_type VARCHAR2(16);
lv_tran_status      VARCHAR2(1);
ln_trans_no         NUMBER;

BEGIN

  -- Set transaction status ACTIVE
  lv_tran_status := 'A';

  -- Find account number and terminal code for the account
  OPEN c_account_info(p_company_id, p_storage_id);
  FETCH c_account_info INTO lv_account_no;
  CLOSE c_account_info;

  -- Find transaction number from ASSIGN_ID
  get_next_id('ACC_TRANSACTION', ln_trans_no);

  lv_transaction_no := to_char(ln_trans_no);

  lv_transaction_type := p_transaction_type;

  -- No support for lifting agreements
  INSERT INTO acc_transaction
     ( account_no, storage_id, transaction_no, daytime, transaction_type, parcel_no, receipt_no, debet, tran_status)
  VALUES
     (lv_account_no, p_storage_id, lv_transaction_no, p_daytime, lv_transaction_type, p_parcel_no, p_batch_no, p_debet, lv_tran_status);

  p_status := 0;

  -- Delete marked transactions
  delete_transaction(p_storage_id, p_status);

  EXCEPTION
    WHEN OTHERS THEN
      p_status := SQLCODE;

END insert_transaction;

---------------------------------------------------------------------
-- Update transaction info
-- Transaction type may be 'PLANNED' or 'LIFTED' for this function.
-- The debet value is used to decide the transaction status. < 0 means that
-- the transaction shall be deleted -> status = 'D'.
----------------------------------------------------------------------
PROCEDURE update_transaction(p_company_id       IN VARCHAR2,
                             p_storage_id       IN VARCHAR2,
                             p_daytime          IN DATE,
                             p_parcel_no        IN NUMBER,
                             p_batch_no         IN NUMBER,
                             p_debet            IN NUMBER,
                             p_transaction_type IN VARCHAR2,
                             p_status           OUT NUMBER)
IS

CURSOR c_account_info(cp_transaction_type VARCHAR2)
IS
SELECT a.account_no, ta.transaction_no, ta.transaction_type
FROM account a, acc_transaction ta
WHERE a.company_id = p_company_id
AND a.storage_id = p_storage_id
AND ta.account_no = a.account_no
AND ta.parcel_no = p_parcel_no
AND ta.transaction_type = cp_transaction_type
AND ta.tran_status = 'A';

-- Local variables
lv_account_no       VARCHAR2(16);
lv_transaction_no   VARCHAR2(16);
lv_transaction_type VARCHAR2(16);
lv_tran_status      VARCHAR2(16);
ln_trans_no         NUMBER;

BEGIN

  -- Find account number, terminal code for the account
  OPEN c_account_info(p_transaction_type);
  FETCH c_account_info INTO lv_account_no, lv_transaction_no, lv_transaction_type;
  CLOSE c_account_info;

  -- Set transaction status
  IF p_debet < 0 THEN

    lv_tran_status := 'D';

    UPDATE acc_transaction
    SET tran_status = lv_tran_status
    WHERE account_no = lv_account_no
    AND storage_id = p_storage_id
    AND parcel_no = p_parcel_no
    AND transaction_no = lv_transaction_no;

  ELSE

    lv_tran_status := 'A';

    --Setting the transaction type
    lv_transaction_type := p_transaction_type;

    -- No support for lifting agreements. Update transaction

      UPDATE acc_transaction
      SET debet = p_debet,
          daytime = p_daytime,
          transaction_type = lv_transaction_type,
          tran_status = lv_tran_status,
          receipt_no = p_batch_no
      WHERE account_no = lv_account_no
      AND storage_id = p_storage_id
      AND parcel_no = p_parcel_no
      AND transaction_no = lv_transaction_no;

  END IF;

  p_status := 0;

  -- Delete marked transactions
  delete_transaction(p_storage_id, p_status);

  EXCEPTION
    WHEN OTHERS THEN
      p_status := SQLCODE;

END update_transaction;

--------------------------------------------------------------
-- Get the next max_id number from assign_id.
--------------------------------------------------------------
PROCEDURE get_next_id(p_tablename IN  VARCHAR2,
                      p_max_id    OUT NUMBER)
IS
CURSOR c_get_max_id(p_tablename VARCHAR2)
IS
SELECT max_id
FROM assign_id
WHERE tablename = p_tablename;

BEGIN

  OPEN c_get_max_id(p_tablename);
  FETCH c_get_max_id INTO p_max_id;

  IF c_get_max_id%NOTFOUND THEN
    INSERT INTO assign_id VALUES (p_tablename, 1);
    p_max_id := 1;
  END IF;

  CLOSE c_get_max_id;

  UPDATE assign_id
  SET max_id = max_id + 1
  WHERE tablename = p_tablename;

END get_next_id;


---------------------------------------------
-- Mark parcel transactions for deletion
---------------------------------------------
PROCEDURE delete_parcel_trans(p_storage_id     IN VARCHAR2,
                            p_parcel_no				 IN NUMBER,
                            p_status           OUT VARCHAR2)
IS
BEGIN

  DELETE FROM acc_transaction
  WHERE storage_id = p_storage_id
  AND parcel_no = p_parcel_no;

	p_status := 0;

  EXCEPTION
    WHEN OTHERS THEN
      p_status := SQLCODE;

END;

---------------------------------------------------------------------
-- Delete transactions marked with 'D'
----------------------------------------------------------------------
PROCEDURE delete_transaction(p_storage_id     IN VARCHAR2,
                             p_status           OUT VARCHAR2)
IS


BEGIN
  -- delete all transactions whith status 'D' -> DELETED.
  DELETE FROM acc_transaction
  WHERE storage_id = p_storage_id
  AND tran_status = 'D';

  p_status := 0;

  EXCEPTION
    WHEN OTHERS THEN
      p_status := SQLCODE;

END delete_transaction;

-------------------------------------------------------------------------
-- Return the 'LIFTED' debet value if it exists, otherwise 'PLANNED' for
-- one account in a parcel.
-------------------------------------------------------------------------
FUNCTION get_transaction_account(p_storage_id VARCHAR2,
								 p_parcel_no NUMBER,
								 p_account_no VARCHAR2)
RETURN NUMBER
IS
CURSOR c_trans(cp_transaction_type VARCHAR2)
IS
SELECT debet
FROM acc_transaction
WHERE storage_id = p_storage_id
AND parcel_no = p_parcel_no
AND account_no = p_account_no
AND transaction_type = cp_transaction_type
AND tran_status = 'A';

ln_parcel_debet 		NUMBER := 0;

BEGIN

	FOR curDebet IN c_trans('LIFTED') LOOP
		ln_parcel_debet := ln_parcel_debet + Nvl(curDebet.debet, 0);
	END LOOP;

	IF ln_parcel_debet = 0 THEN
		FOR curDebet IN c_trans('PLANNED') LOOP
			ln_parcel_debet := ln_parcel_debet + Nvl(curDebet.debet, 0);
		END LOOP;
	END IF;

	RETURN Nvl(ln_parcel_debet, 0);

EXCEPTION
	WHEN OTHERS THEN
		RETURN -1;

END;
END EcBp_Transaction;